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

    def solution_constraints
      @solution_constraints ||= @puzzle.solution_terms.map { |t| @puzzle.constraint(t) }
    end

    # @return [Array<Constraint>]
    def unique_constraints
      @unique_constraints ||= begin
        statistics = Statistics.new(@puzzle)
        solution_constraints.select do |con|
          value = @puzzle.solution.value(con.name)
          statistics.raw_data[con.name][value] == 1
        end
      end
    end

    # @return [Array<Constraint>]
    def sorted_constraints
      @sorted_constraints ||= begin
        fixed_constraints = unique_constraints || [solution_constraints.sample]
        other = (@puzzle.constraints - fixed_constraints).shuffle
        first = other.shift
        (first ? [first] : []) + other + fixed_constraints
      end
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
      # Try to eliminate the exception but allow it if it's the only option
      (@term_values[term] - [except]).sample || @term_values[term].sample
    end

    # @return [void]
    def generate_premises
      last_constraint = nil
      sorted_constraints[0..-2].each do |constraint|
        # next if last_constraint && solution_constraints.include?(constraint) && !unique_constraints.include?(constraint)
        shuffled_pieces = @puzzle.pieces.shuffle
        shuffled_pieces[0..-2].each_with_index do |piece, index|
          @clues.push generate_premise(piece, constraint, last_constraint, affirmation_at(index))
        end
        last_constraint = constraint
      end
      (@puzzle.pieces - [@puzzle.solution]).shuffle.each_with_index do |piece, index|
        @clues.push generate_premise(piece, sorted_constraints.last, last_constraint, affirmation_at(index))
      end
      @clues = [@clues[0]] + @clues[1..-1].shuffle
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
    # @param identifier [Logigram::Constraint]
    # @param affirm [Symbol] :affirmative, :negative, :random
    def generate_premise piece, constraint, identifier, affirm
      value = case affirm
      when :affirmative
        piece.value(constraint.name)
      when :negative
        sample_value(constraint.name, except: piece.value(constraint.name))
      else
        sample_value(constraint.name)
      end
      remove_value constraint.name, value
      Logigram::Premise.new(piece, constraint, value, clarify(piece, identifier))
    end

    # @param piece [Piece]
    # @param identifier [Constraint, nil]
    def clarify piece, identifier
      return nil unless identifier
      total = @puzzle.pieces.select { |p| p.value(identifier.name) == piece.value(identifier.name) }
      total.length == 1 ? identifier : nil
    end
  end
end
