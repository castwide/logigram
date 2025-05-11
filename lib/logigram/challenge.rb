# frozen_string_literal: true

module Logigram
  class Challenge
    # @return [Puzzle]
    attr_reader :puzzle

    attr_reader :difficulty

    def initialize puzzle, difficulty: :medium
      @puzzle = puzzle
      @difficulty = difficulty
    end

    def clues
      @clues ||= generate_clues.shuffle
    end

    private

    def unique_solution_determinants
      @unique_solution_determinants ||= puzzle.determinants.select do |det|
        sol_val = puzzle.solution.value(det.name)
        puzzle.pieces.select { |piece| piece.value(det.name) == sol_val }.one?
      end
    end

    def ambiguous_solution_determinants
      @ambiguous_solution_determinants ||= puzzle.determinants - unique_solution_determinants
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
      # The first constraint to be used for generating clues should not be a
      # determinant
      first = (puzzle.constraints - puzzle.determinants).sample
      ([first] + (puzzle.constraints - [first])).compact
    end

    def generate_clues
      result = []
      last_constraint = nil
      positive = false
      # puzzle.constraints.shuffle.each do |con|
      sorted_constraints.each do |con|
        if unique_solution_determinants.include?(con)
          # Give the first herring a positive premise
          first = herrings.shuffle.first
          value = first.value(con.name)
          result.push Premise.new(first, con, value, last_constraint)
          # Give the rest varying premises based on difficulty
          mixup = puzzle.pieces.shuffle - [first]
          until mixup.one?
            here = mixup.pop
            if difficulty == :easy || (difficulty == :medium && positive)
              result.push Premise.new(here, con, here.value(con.name), last_constraint)
            else
              result.push Premise.new(here, con, mixup.first.value(con.name), last_constraint)
            end
            positive = !positive
          end
          last_constraint = con
        elsif ambiguous_solution_determinants.include?(con)
          # Give the first herring a positive premise
          ambiguous_value = puzzle.solution.value(con.name)
          first = herrings.select { |piece| piece.value(con.name) == ambiguous_value }.sample
          result.push Premise.new(first, con, ambiguous_value, nil)
          # Give the rest varying premises based on difficulty
          mixup = puzzle.pieces.shuffle - [first]
          until mixup.empty?
            here = mixup.pop
            if here == puzzle.solution && difficulty != :easy
              other_value = puzzle.pieces.map { |pc| pc.value(con.name) }.sample
              result.push Premise.new(here, con, other_value, nil)
            else
              if difficulty == :easy || (difficulty == :medium && positive)
                result.push Premise.new(here, con, here.value(con.name), nil)
              else
                result.push Premise.new(here, con, ambiguous_value, nil)
              end
            end
            positive = !positive
          end
          last_constraint = nil
        elsif unique_constraints.include?(con)
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
          last_constraint = con
        else
          # Ambiguous constraint
          ambiguous_value = puzzle.solution.value(con.name)
          mixup = puzzle.pieces.shuffle
          until mixup.empty?
            here = mixup.pop
            if here == puzzle.solution && difficulty != :easy
              other_value = puzzle.pieces.map { |pc| pc.value(con.name) }.sample
              result.push Premise.new(here, con, other_value, nil)
            else
              if difficulty == :easy || (difficulty == :medium && positive)
                result.push Premise.new(here, con, here.value(con.name), nil)
              else
                result.push Premise.new(here, con, ambiguous_value, nil)
              end
            end
            positive = !positive
          end
          last_constraint = nil
        end
      end
      result
    end
  end
end
