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
      reductions = []
      previous = nil
      @sorted = @puzzle.constraints.shuffle.sort { |a, b| (b.name == @puzzle.solution_term ? 0 : 1) }
      constraint_premises = []
      @sorted.each_with_index do |constraint, idx|
        here = generate_premises(constraint, reductions, previous)
        reductions.clear
        constraint_premises.push here
        unless @sorted.last == constraint
          here, _ = generate_premise(@puzzle.pieces.last, @sorted[idx + 1], constraint, [@puzzle.pieces.last], here.map { |pr| pr.value })
          constraint_premises.last.push here
          reductions.push here
        end
        previous = constraint
      end
      flat = constraint_premises.flatten
      @clues = [flat[0]] + flat[1..-1].shuffle
    end

    private

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
        # Sometimes we can wind up here even though the piece's current value is the only available option
        (values - used - [piece.value(constraint.name)]).sample || piece.value(constraint.name)
      else
        piece.value(constraint.name)
      end
      [Logigram::Premise.new(piece, constraint, value, parent), value]
    end
  end
end
