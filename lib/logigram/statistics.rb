# frozen_string_literal: true

module Logigram
  # A data summary about the pieces and premises of a puzzle.
  #
  # @param puzzle [Logigram::Base]
  # @param subject [String]
  # @param plural [String]
  class Statistics
    def initialize puzzle, subject: 'thing', plural: "#{subject}s"
      @puzzle = puzzle
      @subject = subject
      @plural = plural
    end

    # @return [Hash]
    def raw_data
      @raw_data ||= Datasets.constraint_tables(@puzzle)
    end

    # @return [Array<String>]
    def statements
      @statements ||= generate_statements
    end

    private

    def noun qty
      qty == 1 ? @subject : @plural
    end

    def generate_statements
      lines = []
      raw_data.each_pair do |key, values|
        con = @puzzle.constraint(key)
        values.each_pair do |val, qty|
          lines.push "#{qty} #{noun(qty)} #{con.predicate(val, qty)}"
        end
      end
      lines
    end
  end
end
