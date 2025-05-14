# frozen_string_literal: true

module Logigram
  module Generator
    # The base class for generating premises for a puzzle.
    #
    class Base
      # @return [Puzzle]
      attr_reader :puzzle

      # @return [Hash{Symbol => Object}]
      attr_reader :options

      # @param puzzle [Puzzle]
      def initialize(puzzle, **options)
        @puzzle = puzzle
        configure(**options)
      end

      # @param options [Hash{Symbol => Object}]
      def configure **options
        @options = options
      end

      # @return [Array<Premise>]
      def premises
        raise 'not implemented'
      end
    end
  end
end
