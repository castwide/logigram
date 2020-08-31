module Logigram
  # Use the Logigram::Challenge class to generate a list of clues from a
  # puzzle.
  #
  class Challenge
    # @return [Array<Logigram::Premise>]
    attr_reader :clues

    # @param puzzle [Logigram::Base]
    def initialize puzzle
      @puzzle = puzzle
      @premises = []
      reductions = []
      previous = nil
      result = []
      @sorted = @puzzle.constraints.values.sort { |a, b| (b.name == @puzzle.solution_term ? 0 : 1) }
      @sorted.each_with_index do |constraint, idx|
        here = generate_premises(constraint, reductions, previous)
        reductions.clear
        result.concat here
        unless @sorted.last == constraint
          here, _ = generate_premise(@puzzle.pieces.last, @sorted[idx + 1], constraint, [@puzzle.pieces.last], here.map { |pr| pr.value })
          result.push here
          reductions.push here
        end
        previous = constraint
      end
      @clues = [result[0]] + result[1..-1].shuffle
    end

    # @param constraint [Logigram::Constraint]
    # @param reductions [Array<Logigram::Piece>]
    # @param parent [Logigram::Constraint]
    # @return [Array<Logigram::Premise>]
    def generate_premises constraint, reductions, parent
      result = []
      passed = false
      used = []
      @puzzle.pieces[0..-2].each do |piece|
        reductions.push piece if passed
        # next if used.include?(piece.value(constraint.name))
        premise, last = generate_premise(piece, constraint, parent, reductions, used)
        result.push premise
        used.push last
        passed = true
      end
      result
    end

    def generate_premise piece, constraint, parent, reductions, used
      value = if reductions.include?(piece) || (piece == @puzzle.solution && @puzzle.solution_term == constraint.name)
        values = @puzzle.pieces.map { |pc| pc.value(constraint.name) }
        (values - used - [piece.value(constraint.name)]).sample
      else
        piece.value(constraint.name)
      end
      [Logigram::Premise.new(piece, constraint, value, parent), value]
    end
  end
end
