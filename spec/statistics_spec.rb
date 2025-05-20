# frozen_string_literal: true

RSpec.describe Logigram::Statistics do
  describe '.constraint_tables' do
    it 'reports the number of pieces for each value of each constraint' do
      constraint = Logigram::Constraint.new('color', %w[red blue], reserve: 'red', unique: false)
      puzzle = Logigram::Puzzle.new(constraints: [constraint], objects: %w[1 2 3])
      table = Logigram::Statistics.constraint_tables(puzzle)

      # There should always be 2 blue pieces and 1 red piece because the
      # solution must be red
      expect(table[constraint]['blue']).to eq(2)
      expect(table[constraint]['red']).to eq(1)
    end
  end
end
