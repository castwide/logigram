# frozen_string_literal: true

module Logigram
  # Use Logigram::Challenge to generate a list of premises from a puzzle.
  #
  class Challenge
    # @return [Puzzle]
    attr_reader :puzzle

    # :easy   - all affirmative premises
    # :medium - mixture of affirmative and negative premises
    # :hard   - minimal affirmative premises
    #
    # @return [Symbol]
    attr_reader :difficulty

    # @param puzzle [Puzzle]
    # @param difficulty [Symbol] :easy, :medium, or :hard
    def initialize(puzzle, difficulty: :medium)
      @puzzle = puzzle
      @difficulty = difficulty
    end

    def premises
      @premises ||= generate_premises.shuffle
    end
    alias clues premises

    private

    def unique_determinants
      @unique_determinants ||= puzzle.determinants.select do |det|
        sol_val = puzzle.solution.value(det.name)
        puzzle.pieces.select { |piece| piece.value(det.name) == sol_val }.one?
      end
    end

    def ambiguous_determinants
      @ambiguous_determinants ||= puzzle.determinants - unique_determinants
    end

    def unique_constraints
      @unique_constraints ||= (puzzle.constraints - puzzle.determinants).select do |con|
        puzzle.pieces.map { |piece| piece.value(con.name) }.uniq.length == puzzle.pieces.length
      end
    end

    # All pieces except the solution
    #
    def herrings
      puzzle.pieces - [puzzle.solution]
    end

    def sorted_constraints
      # Premises for determinants should always be generated last
      @sorted_constraints ||= (puzzle.constraints - puzzle.determinants).shuffle + puzzle.determinants.shuffle
    end

    def generate_premises
      result = []
      last_constraint = nil
      sorted_constraints.each_with_index do |con, idx|
        if unique_determinants.include?(con)
          final = idx == (sorted_constraints.length - 1)
          result.concat generate_unique_determinant_premises(con, final, last_constraint)
          last_constraint = con
        elsif ambiguous_determinants.include?(con)
          result.concat generate_ambiguous_determinant_premises(con, final, last_constraint)
          last_constraint = nil
        elsif unique_constraints.include?(con)
          result.concat generate_unique_constraint_premises(con, final, last_constraint)
          last_constraint = con
        else
          result.concat generate_ambiguous_constraint_premises(con, final, last_constraint)
          last_constraint = nil
        end
      end
      result
    end

    def generate_unique_determinant_premises(con, final, last_constraint)
      result = []
      positive = false
      # Give the first herring a positive premise
      first = herrings.sample
      value = first.value(con.name)
      result.push Premise.new(first, con, value, last_constraint)
      # Give the rest varying premises based on difficulty
      mixup = puzzle.pieces.shuffle - [first]
      until final ? mixup.one? : mixup.length < 3
        here = mixup.pop
        if difficulty == :easy || (difficulty == :medium && positive)
          result.push Premise.new(here, con, here.value(con.name), last_constraint)
        else
          result.push Premise.new(here, con, mixup.first.value(con.name), last_constraint)
        end
        positive = !positive
      end
      result
    end

    def generate_ambiguous_determinant_premises(con, final, _last_constraint)
      result = []
      positive = false
      # Give the first herring a positive premise
      ambiguous_value = puzzle.solution.value(con.name)
      first = herrings.select { |piece| piece.value(con.name) == ambiguous_value }.sample
      result.push Premise.new(first, con, ambiguous_value, nil)
      # Give the rest varying premises based on difficulty
      mixup = puzzle.pieces.shuffle - [first]
      until final ? mixup.one? : mixup.length < 3
        here = mixup.pop
        if here == puzzle.solution && difficulty != :easy
          other_value = puzzle.pieces.map { |pc| pc.value(con.name) }.sample
          result.push Premise.new(here, con, other_value, nil)
        elsif difficulty == :easy || (difficulty == :medium && positive)
          result.push Premise.new(here, con, here.value(con.name), nil)
        else
          result.push Premise.new(here, con, ambiguous_value, nil)
        end
        positive = !positive
      end
      result
    end

    def generate_unique_constraint_premises(con, _final, last_constraint)
      result = []
      positive = false
      # Give one a positive premise
      mixup = puzzle.pieces.shuffle
      here = mixup.pop
      result.push Premise.new(here, con, here.value(con.name), last_constraint)
      # Give the rest varying premises based on difficulty
      until mixup.one?
        here = mixup.pop
        if difficulty == :easy || (difficulty == :medium && positive)
          result.push Premise.new(here, con, here.value(con.name), last_constraint)
        else
          result.push Premise.new(here, con, mixup.first.value(con.name), last_constraint)
        end
        positive = !positive
      end
      result
    end

    def generate_ambiguous_constraint_premises(con, _final, _last_constraint)
      result = []
      positive = false
      # Ambiguous constraint
      ambiguous_value = puzzle.solution.value(con.name)
      mixup = puzzle.pieces.shuffle
      until mixup.one?
        here = mixup.pop
        if here == puzzle.solution && difficulty != :easy
          other_value = puzzle.pieces.map { |pc| pc.value(con.name) }.sample
          result.push Premise.new(here, con, other_value, nil)
        elsif difficulty == :easy || (difficulty == :medium && positive)
          result.push Premise.new(here, con, here.value(con.name), nil)
        else
          result.push Premise.new(here, con, ambiguous_value, nil)
        end
        positive = !positive
      end
      result
    end
  end
end
