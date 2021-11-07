RSpec.describe Logigram::Challenge do
  let(:puzzle) {
    klass = Class.new(Logigram::Base) do
      constrain 'color', ['red', 'blue', 'green']
      constrain 'size', ['small', 'medium', 'large']
    end
    klass.new(['dog', 'cat', 'pig'])
  }

  it 'generates clues' do
    challenge = Logigram::Challenge.new(puzzle)
    expect(challenge.clues).not_to be_empty
  end

  it 'excludes the solution predicate from the clues' do
    challenge = Logigram::Challenge.new(puzzle)
    strings = challenge.clues.map(&:to_s)
    expect(strings).not_to include("#{puzzle.solution} #{puzzle.solution_predicate}")
  end

  it 'generates easy clues' do
    challenge = Logigram::Challenge.new(puzzle, difficulty: :easy)
    expect(challenge.clues.length).to eq(4)
    expect(challenge.clues.all?(&:affirmative?)).to be(true)
  end

  it 'generates hard clues' do
    challenge = Logigram::Challenge.new(puzzle, difficulty: :hard)
    expect(challenge.clues.select(&:affirmative?).length).to eq(2)
  end

  it 'supports multiple terms' do
    klass = Class.new(Logigram::Base) do
      constrain 'color', ['red', 'green', 'blue']
      constrain 'size', ['small', 'medium', 'large']
      constrain 'height', ['short', 'average', 'tall']
    end
    # @type [Logigram::Base]
    puzzle = klass.new(['dog', 'cat', 'mouse'], terms: ['color', 'size'])
    [:easy, :medium, :hard].each do |diff|
      expect { Logigram::Challenge.new(puzzle, difficulty: diff) }.not_to raise_error
    end
  end
end
