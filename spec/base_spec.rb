RSpec.describe Logigram::Base do
  it 'accepts constraints' do
    klass = Class.new(Logigram::Base) do
      constrain 'color', ['red', 'green', 'blue']
    end
    # @type [Logigram::Base]
    puzzle = klass.new(['dog', 'cat', 'pig'])
    expect(puzzle.constraints.map(&:name)).to eq(['color'])
    expect(puzzle.constraint('color').values).to eq(['red', 'green', 'blue'])
  end

  it 'accepts a solution' do
    klass = Class.new(Logigram::Base) do
      constrain 'color', ['red', 'green', 'blue']
    end
    # @type [Logigram::Base]
    puzzle = klass.new(['dog', 'cat', 'pig'], solution: 'dog')
    expect(puzzle.solution.name).to eq('dog')
  end

  it 'sets a random solution' do
    klass = Class.new(Logigram::Base) do
      constrain 'color', ['red', 'green', 'blue']
    end
    # @type [Logigram::Base]
    puzzle = klass.new(['dog', 'cat', 'pig'])
    expect(puzzle.pieces).to include(puzzle.solution)
    expect(['dog', 'cat', 'pig']).to include(puzzle.solution.name)
  end

  it 'generates premises' do
    klass = Class.new(Logigram::Base) do
      constrain 'color', ['red', 'green', 'blue']
      constrain 'size', ['small', 'medium', 'large']
    end
    # @type [Logigram::Base]
    puzzle = klass.new(['dog', 'cat', 'pig'])
    expect(puzzle.premises).not_to be_empty
  end

  it 'raises an error for insufficient constraint values' do
    klass = Class.new(Logigram::Base) do
      constrain 'color', ['red']
    end
    expect {
      klass.new(['dog', 'cat'])
    }.to raise_error(RuntimeError)
  end

  it 'selects a solution predicate' do
    klass = Class.new(Logigram::Base) do
      constrain 'color', ['red']
    end
    # @type [Logigram::Base]
    puzzle = klass.new(['dog'])
    expect(puzzle.solution_term).to eq('color')
    expect(puzzle.solution_predicate).to eq('is red')
  end

  it 'sets a random solution term' do
    klass = Class.new(Logigram::Base) do
      constrain 'color', ['red']
      constrain 'size', ['small']
    end
    # @type [Logigram::Base]
    puzzle = klass.new(['dog'])
    expect(['color', 'size']).to include(puzzle.solution_term)
  end

  it 'uses reserves for solutions' do
    klass = Class.new(Logigram::Base) do
      constrain 'color', ['red', 'green', 'blue'], reserve: 'blue'
    end
    # @type [Logigram::Base]
    puzzle = klass.new(['dog', 'cat'])
    expect(puzzle.solution.value('color')).to eq('blue')
  end
end
