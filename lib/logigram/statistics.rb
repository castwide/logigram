module Logigram
  class Statistics
    def initialize puzzle, subject: 'thing', plural: "#{subject}s"
      @puzzle = puzzle
      @subject = subject
      @plural = plural
    end

    def raw_data
      @raw_data ||= generate_statistics
    end

    def statements
      @statements ||= generate_statements
    end

    def to_s
      statements.join("\n")
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
