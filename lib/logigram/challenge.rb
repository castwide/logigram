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
      @clues = []
      @term_values = {}
      generate_premises
    end

    private

    # @return [Array<Constraint>]
    def shuffled_constraints
      @shuffled_constraints ||= (@puzzle.constraints - [@puzzle.constraint(@puzzle.solution_term)]).shuffle + [@puzzle.constraint(@puzzle.solution_term)]
    end

    def remove_value term, value
      @term_values[term] ||= @puzzle.term_values(term)
      @term_values[term].delete value
    end

    def sample_value term, except = nil
      @term_values[term] ||= @puzzle.term_values(term)
      (@term_values[term] - [except]).sample
    end

    def generate_premises
      last_constraint = nil
      shuffled_constraints[0..-2].each do |constraint|
        @puzzle.pieces.shuffle[0..-2].each_with_index do |piece, index|
          @clues.push generate_premise(piece, constraint, last_constraint, index < @puzzle.pieces.length - 2)
        end
        last_constraint = constraint
      end
      (@puzzle.pieces - [@puzzle.solution]).shuffle.each_with_index do |piece, index|
        @clues.push generate_premise(piece, shuffled_constraints.last, last_constraint, index < @puzzle.pieces.length - 2)
      end
      @clues = [@clues[0]] + @clues[1..-1].shuffle
    end

    # @param piece [Logigram::Piece]
    # @param constraint [Logigram::Constraint]
    def generate_premise piece, constraint, identifier, affirm
      value = affirm ? piece.value(constraint.name) : sample_value(constraint.name)
      remove_value constraint.name, value
      Logigram::Premise.new(piece, constraint, value, identifier)
    end
  end
end
