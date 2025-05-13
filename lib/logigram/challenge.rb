# frozen_string_literal: true

module Logigram
  # Use Logigram::Challenge to generate a list of premises from a puzzle.
  #
  class Challenge
    # @return [Puzzle]
    attr_reader :puzzle

    # @return [Symbol]
    attr_reader :difficulty

    # @param puzzle [Puzzle]
    # @param difficulty [Symbol] :easy, :medium, or :hard
    def initialize(puzzle, difficulty: :medium)
      @puzzle = puzzle
      @difficulty = difficulty
    end

    # @return [Array<Premise>]
    def premises
      @premises ||= generate_premises
    end
    alias clues premises

    private

    def generate_premises
      result = []
      last_constraint = nil
      # The first premise will be affirmative and specific, but since it
      # shouldn't be derived from a determinant, it can be the solution
      pieces = puzzle.pieces.shuffle
      (unique_constraints + unique_determinants).each do |constraint|
        result.concat generate_unique_premises(constraint, pieces, last_constraint)
        shuffle_pieces!(pieces)
        last_constraint = constraint
      end
      (ambiguous_constraints + ambiguous_determinants).each do |constraint|
        result.concat generate_unique_premises(constraint, pieces, random_unique_constraint)
        shuffle_pieces!(pieces)
      end
      result
    end

    def shuffle_pieces!(pieces)
      last = pieces.pop
      pieces.shuffle!
      pieces.unshift last
      pieces.delete puzzle.solution
      pieces.push puzzle.solution
    end

    # @param constraint [Constraint]
    # @param pieces [Array<Piece>]
    # @param last_constraint [Constraint]
    def generate_unique_premises(constraint, pieces, last_constraint)
      pieces[0..-2].map.with_index do |piece, idx|
        if idx.zero? || difficulty == :easy || (difficulty == :medium && idx.even?)
          Premise.new(piece, constraint, piece.value(constraint.name), last_constraint)
        else
          Premise.new(piece, constraint, pieces[idx + 1].value(constraint.name), last_constraint)
        end
      end
    end

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

    def ambiguous_constraints
      @ambiguous_constraints ||= puzzle.constraints - puzzle.determinants - unique_constraints
    end

    def random_unique_constraint
      @random_unique_constraints ||= (unique_constraints + unique_determinants).shuffle
      if @random_unique_constraints.empty?
        @random_unique_constraints.replace((unique_constraints + unique_determinants).shuffle)
      end
      @random_unique_constraints.pop
    end
  end
end
