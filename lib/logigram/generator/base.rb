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
      # @return [void]
      def configure **options
        @options = options
      end

      # @abstract
      # @!method premises
      #   @return [Array<Premise>]
    end
  end
end
