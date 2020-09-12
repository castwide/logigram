module Logigram
  # Use the Logigram::Challenge class to generate a list of clues from a
  # puzzle.
  #
  class Challenge
    # @return [Array<Logigram::Premise>]
    attr_reader :clues

    # @param puzzle [Logigram::Base]
    # @param difficulty [Symbol] :easy, :medium, :hard, or :long
    def initialize puzzle, difficulty: :medium
      @puzzle = puzzle
      @clues = []
      @term_values = {}
      @difficulty = difficulty
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
        shuffled_pieces = @puzzle.pieces.shuffle
        shuffled_pieces[0..-2].each_with_index do |piece, index|
          @clues.push generate_premise(piece, constraint, last_constraint, affirmation_at(index))
        end
        # if @difficulty == :hard
        #   @clues.push generate_premise(shuffled_pieces.last, constraint, last_constraint, :negative)
        # end
        last_constraint = constraint
      end
      (@puzzle.pieces - [@puzzle.solution]).shuffle.each_with_index do |piece, index|
        @clues.push generate_premise(piece, shuffled_constraints.last, last_constraint, affirmation_at(index))
      end
      # if @difficulty == :hard
      #   @clues.push generate_premise(@puzzle.solution, shuffled_constraints.last, last_constraint, :negative)
      # end
      # @clues = [@clues[0]] + @clues[1..-1].shuffle
    end

    def affirmation_at index
      if @difficulty == :easy
        :affirmative
      elsif @difficulty == :medium
        if index < @puzzle.pieces.length - 2
          :affirmative
        else
          :random
        end
      elsif @difficulty == :hard
        if index == 0
          :affirmative
        else
          :negative
        end
      end
    end

    # @param piece [Logigram::Piece]
    # @param constraint [Logigram::Constraint]
    # @param force [Symbol] :affirmative, :negative, :random
    def generate_premise piece, constraint, identifier, affirm
      value = case affirm
      when :affirmative
        piece.value(constraint.name)
      when :negative
        sample_value(constraint.name, piece.value(constraint.name))
      else
        sample_value(constraint.name)
      end
      # value = affirm ? piece.value(constraint.name) : sample_value(constraint.name)
      remove_value constraint.name, value
      Logigram::Premise.new(piece, constraint, value, identifier)
    end
  end
end
