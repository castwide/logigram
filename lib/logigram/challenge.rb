module Logigram
  # Use the Logigram::Challenge class to generate a list of clues from a
  # puzzle.
  #
  # Challenges have three degrees of difficulty.
  # - easy: all affirmative premises
  # - medium: mixture of affirmative and negative premises
  # - hard: one affirmative premise per constraint
  #
  class Challenge
    # @return [Array<Logigram::Premise>]
    attr_reader :clues

    # @param puzzle [Logigram::Base]
    # @param difficulty [Symbol] :easy, :medium, :hard
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

    # Remove a value from a term's availability list.
    #
    # @param term [String]
    # @param value [String]
    # @return [void]
    def remove_value term, value
      @term_values[term] ||= @puzzle.term_values(term)
      @term_values[term].delete value
    end

    # Get a random value from a term's availability list.
    #
    # @param term [String]
    # @param except [String, nil]
    def sample_value term, except: nil
      @term_values[term] ||= @puzzle.term_values(term)
      (@term_values[term] - [except]).sample
    end

    # @return [void]
    def generate_premises
      last_constraint = nil
      shuffled_constraints[0..-2].each do |constraint|
        shuffled_pieces = @puzzle.pieces.shuffle
        shuffled_pieces[0..-2].each_with_index do |piece, index|
          @clues.push generate_premise(piece, constraint, last_constraint, affirmation_at(index))
        end
        last_constraint = constraint
      end
      (@puzzle.pieces - [@puzzle.solution]).shuffle.each_with_index do |piece, index|
        @clues.push generate_premise(piece, shuffled_constraints.last, last_constraint, affirmation_at(index))
      end
    end

    # @param index [Integer]
    # @return [Symbol]
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
        sample_value(constraint.name, except: piece.value(constraint.name))
      else
        sample_value(constraint.name)
      end
      # value = affirm ? piece.value(constraint.name) : sample_value(constraint.name)
      remove_value constraint.name, value
      Logigram::Premise.new(piece, constraint, value, identifier)
    end
  end
end
