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
      @raw_data ||= generate_statistics
    end

    # @return [Array<String>]
    def statements
      @statements ||= generate_statements
    end

    private

    def noun qty
      qty == 1 ? @subject : @plural
    end

    def generate_statistics
      stats = {}
      @puzzle.constraints.each do |con|
        values = {}
        @puzzle.pieces.each do |pc|
          values[pc.value(con.name)] ||= 0
          values[pc.value(con.name)] += 1
        end
        stats[con.name] = values
      end
      stats
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
