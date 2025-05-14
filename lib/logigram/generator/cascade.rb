# frozen_string_literal: true

module Logigram
  module Generator
    # A generator that cascades through a puzzle's constraints.
    #
    class Cascade < Base
      attr_reader :difficulty

      def configure(difficulty: :medium)
        @difficulty = difficulty
      end

      def premises
        (generate_unique_premises + generate_ambiguous_premises).shuffle
      end

      private

      def generate_unique_premises
        last_constraint = nil
        (unique_constraints + unique_determinants).flat_map do |constraint|
          next_constraint_premises(constraint, last_constraint).tap do
            reshuffle_pieces
            last_constraint = constraint
          end
        end
      end

      def generate_ambiguous_premises
        (ambiguous_constraints + ambiguous_determinants).flat_map do |constraint|
          next_constraint_premises(constraint, pick_random_unique_constraint).tap { reshuffle_pieces }
        end
      end

      # @return [Array<Piece>]
      def shuffled_pieces
        @shuffled_pieces ||= puzzle.pieces.shuffle
      end

      def reshuffle_pieces
        # Constraint premise generation doesn't make a premise for the last
        # piece in the list. Move it to the front before the next iteration to
        # ensure that each piece (with the possible exception of the solution)
        # gets at least one premise
        last = shuffled_pieces.pop
        shuffled_pieces.shuffle!
        shuffled_pieces.unshift last
        # Avoid making more than one premise for the solution
        shuffled_pieces.delete puzzle.solution
        shuffled_pieces.push puzzle.solution
      end

      # @param constraint [Constraint]
      # @param pieces [Array<Piece>]
      # @param last_constraint [Constraint, nil]
      def next_constraint_premises(constraint, last_constraint)
        shuffled_pieces[0..-2].map.with_index do |piece, idx|
          key = constraint.name
          premise_value = should_be_easy?(idx) ? piece.value(key) : shuffled_pieces[-idx].value(key)
          Premise.new(piece, constraint, premise_value, last_constraint)
        end
      end

      def should_be_easy?(idx)
        idx.zero? || difficulty == :easy || (difficulty == :medium && idx.even?)
      end

      def unique_determinants
        @unique_determinants ||= puzzle.determinants.select do |con|
          puzzle.pieces.map { |piece| piece.value(con.name) }.uniq.length == puzzle.pieces.length
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

      def pick_random_unique_constraint
        random_unique_constraints.replace(shuffle_unique_constraints) if random_unique_constraints.empty?
        random_unique_constraints.pop
      end

      def random_unique_constraints
        @random_unique_constraints ||= shuffle_unique_constraints
      end

      def shuffle_unique_constraints
        (unique_constraints + unique_determinants).shuffle
      end
    end
  end
end
