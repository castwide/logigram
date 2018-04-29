module Logigram
  # Use the Logigram::Challenge class to generate a list of clues from a
  # puzzle.
  #
  class Challenge
    # @return [Array<Logigram::Premise>]
    attr_reader :clues
    # @return [Array<Logigram::Premise>]
    attr_reader :extras

    def initialize puzzle
      @puzzle = puzzle
      @premises = @puzzle.premises.clone
      @clues = []

      # Eliminate the premise that would solve the puzzle with one clue, e.g.,
      # if the solution has red hair, eliminate "Bob has red hair."
      eliminate piece: @puzzle.solution_piece, term: @puzzle.solution_term, affirmative: true, specific: true
      eliminate term: @puzzle.solution_term, affirmative: true, specific: true # Higher difficulty
      eliminate term: @puzzle.solution_term, affirmative: true, specific: false # Even higher (generic premises that reveal the solution constraint with a generic subject)
      eliminate term: @puzzle.solution_term, affirmative: false, specific: true, value: @puzzle.solution.value(@puzzle.solution_term) # Specific negative premises about the solution facet
      (@puzzle.pieces - [@puzzle.pieces.sample]).each do |p|
        specify(p)
      end
      eliminate affirmative: true, specific: true # Eliminate all remaining specific true premises
      @puzzle.pieces.each do |p|
        specify(p, false)
      end
      eliminate term: @puzzle.solution_term, affirmative: true, specific: false # Eliminate affirmative generic premises about the solution facet
      eliminate piece: @puzzle.solution, specific: false # Eliminate all generic premises about the solution piece
      @puzzle.pieces.each do |p|
        implicate(p, true)
      end
      @puzzle.pieces.each do |p|
        implicate(p, false)
        implicate(p, false)
      end
      @clues = [@clues[0]] + clues[1..-1].shuffle
      @extras = @premises.clone.shuffle
    end

    private

    def specify piece, affirmative = true
      opts = []
      @premises.each do |p|
        opts.push p if p.fit(piece: piece, affirmative: affirmative, specific: true)
      end
      result = opts.sample
      return if result.nil?
      @premises.delete result
      eliminate piece: piece, term: result.term, specific: true
      eliminate term: result.term, affirmative: false, value: result.value
      @clues.push result
    end

    def implicate piece, affirmative = true
      opts = []
      @premises.each do |p|
        opts.push p if p.fit(piece: piece, affirmative: affirmative, specific: false)
      end
      result = opts.sample
      return if result.nil?
      @premises.delete result
      eliminate piece: piece, term: result.term, affirmative: true, specific: true
      eliminate piece: piece, term: result.term, specific: false if affirmative # Remove generic premises that match affirmative premise
      @clues.push result
    end

    def eliminate piece: nil, term: nil, affirmative: nil, specific: nil, value: nil, name: nil
      @premises.delete_if { |p|
        p.fit(piece: piece, term: term, affirmative: affirmative, specific: specific, value: value, name: name)
      }
    end
  end
end
