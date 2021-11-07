module Logigram
  class Statistics
    def initialize puzzle
      @puzzle = puzzle
    end

    def statistics
      @statistics ||= generate_statistics
    end

    def to_s
      lines = []
      statistics.each_pair do |con, values|
        values.each_pair do |val, qty|
          lines.push "#{con.name} = #{val}: #{qty}"
        end
      end
      puts lines.join("\n")
    end

    private

    def generate_statistics
      stats = {}
      @puzzle.constraints.each do |con|
        values = {}
        @puzzle.pieces.each do |pc|
          values[pc.value(con.name)] ||= 0
          values[pc.value(con.name)] += 1
        end
        stats[con] = values
      end
      stats
    end
  end
end
