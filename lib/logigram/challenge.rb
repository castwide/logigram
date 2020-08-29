module Logigram
  # Use the Logigram::Challenge class to generate a list of clues from a
  # puzzle.
  #
  class Challenge
    # @return [Array<Logigram::Premise>]
    attr_reader :clues

    # @return [Array<Logigram::Premise>]
    attr_reader :extras

    # @param puzzle [Logigram::Puzzle]
    def initialize puzzle
      @puzzle = puzzle
      @premises = @puzzle.premises.clone
      @clues = []

      # Eliminate the premise that would solve the puzzle with one clue, e.g.,
      # if the solution has red hair, eliminate "Bob has red hair."
      eliminate piece: @puzzle.solution, term: @puzzle.solution_term, affirmative: true, specific: true
      # Higher difficulty
      eliminate term: @puzzle.solution_term, affirmative: true, specific: true
      # Even higher (generic premises that reveal the solution constraint with a generic subject)
      eliminate term: @puzzle.solution_term, affirmative: true, specific: false
      # Specific negative premises about the solution facet
      eliminate term: @puzzle.solution_term, affirmative: false, specific: true, value: @puzzle.solution.value(@puzzle.solution_term)
      (@puzzle.pieces - [@puzzle.pieces.sample]).each do |p|
        specify(p)
      end
      # Eliminate all remaining specific true premises
      eliminate affirmative: true, specific: true
      @puzzle.pieces.each do |p|
        specify(p, false)
      end
      # Eliminate affirmative generic premises about the solution facet
      eliminate term: @puzzle.solution_term, affirmative: true, specific: false
      # Eliminate all generic premises about the solution piece
      eliminate piece: @puzzle.solution, specific: false
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
      # Remove generic premises that match affirmative premise
      eliminate piece: piece, term: result.term, specific: false if affirmative
      @clues.push result
    end

    def eliminate piece: nil, term: nil, affirmative: nil, specific: nil, value: nil, name: nil
      @premises.delete_if { |p|
        p.fit(piece: piece, term: term, affirmative: affirmative, specific: specific, value: value, name: name)
      }
    end
  end
end
