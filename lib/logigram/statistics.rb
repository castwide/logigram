# frozen_string_literal: true

module Logigram
  # Methods for collecting puzzle data.
  #
  module Statistics
    module_function

    # @param puzzle [Puzzle]
    # @return [Hash{Constraint => Hash{String => Integer}}]
    def constraint_tables(puzzle)
      puzzle.constraints.map do |con|
        values = {}
        puzzle.pieces.each do |pc|
          values[pc.value(con)] ||= 0
          values[pc.value(con)] += 1
        end
        [con, values]
      end.to_h
    end
  end
end
