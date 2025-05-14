# frozen_string_literal: true

module Logigram
  module Generator
    # The base class for generating premises for a puzzle.
    #
    class Base
      attr_reader :puzzle

      # @param puzzle [Puzzle]
      def initialize(puzzle)
        @puzzle = puzzle
      end

      # @return [Array<Premise>]
      def premises
        @premises ||= []
      end
    end
  end
end
