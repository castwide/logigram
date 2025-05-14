# frozen_string_literal: true

module Logigram
  module Generator
    # Generate all possible premises for a puzzle.
    #
    class All < Base
      def premises
        puzzle.pieces.flat_map { |pc| generate_piece_premises pc }
      end

      private

      # @param piece [Piece]
      # @return [Array<Premise>]
      def generate_piece_premises(piece)
        piece.properties.flat_map do |property|
          [Premise.new(piece, property.constraint, property.value)] +
            positive_generic_premises(piece, property) +
            negative_specific_premises(piece, property) +
            negative_generic_premises(piece, property)
        end
      end

      # @param piece [Piece]
      # @param property [Property]
      def positive_generic_premises(piece, property)
        (piece.properties - [property]).map do |other_property|
          Premise.new(piece, property.constraint, property.value, other_property.constraint)
        end
      end

      # @param piece [Piece]
      # @param property [Property]
      def negative_specific_premises(piece, property)
        (puzzle.pieces - [piece]).map do |other_piece|
          other_value = other_piece.value(property.constraint)
          Premise.new(piece, property.constraint, other_value)
        end
      end

      # @param piece [Piece]
      # @param property [Property]
      def negative_generic_premises(piece, property)
        (piece.properties - [property]).map do |other_property|
          (puzzle.pieces - [piece]).each do |other_piece|
            other_value = other_piece.value(property.constraint)
            Premise.new(piece, property.constraint, other_value, other_property.constraint)
          end
        end
      end
    end
  end
end
