# frozen_string_literal: true

RSpec.describe Logigram::Puzzle do
  describe '#herrings' do
    it 'includes all pieces except the solution' do
      puzzle = Logigram::Puzzle.new(
        constraints: [Logigram::Constraint.new('color', %w[red blue green])],
        objects: %w[1 2 3]
      )

      expect(puzzle.herrings).to match_array(puzzle.pieces - [puzzle.solution])
    end
  end

  describe '#to_challenge' do
    it 'returns a Challenge object' do
      puzzle = Logigram::Puzzle.new(
        constraints: [Logigram::Constraint.new('color', %w[red blue green])],
        objects: %w[1 2 3]
      )

      challenge = puzzle.to_challenge

      expect(challenge).to be_a(Logigram::Challenge)
      expect(challenge.puzzle).to eq(puzzle)
    end
  end
end
