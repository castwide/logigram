RSpec.describe Logigram::Base do
  it 'accepts constraints' do
    klass = Class.new(Logigram::Base) do
      constrain 'color', 'red', 'green', 'blue'
    end
    # @type [Logigram::Base]
    puzzle = klass.new(['the dog', 'the cat', 'the pig'])
    expect(puzzle.terms).to eq(['color'])
    expect(puzzle.constraints['color'].values).to eq(['red', 'green', 'blue'])
  end
end
