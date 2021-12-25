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

  it 'supports multiple terms' do
    klass = Class.new(Logigram::Base) do
      constrain 'color', ['red', 'green', 'blue']
      constrain 'size', ['small', 'medium', 'large']
      constrain 'height', ['short', 'average', 'tall']
    end
    # @type [Logigram::Base]
    puzzle = klass.new(['dog', 'cat'], terms: ['color', 'size'])
    expect(puzzle.solution_terms).to eq(['color', 'size'])
  end

  it 'allows duplicate values' do
    klass = Class.new(Logigram::Base) do
      constrain 'color', ['red', 'green']
    end
    # @type [Logigram::Base]
    puzzle = klass.new(['pencil', 'pen', 'crayon'])
    answer = puzzle.solution.value('color')
    (puzzle.pieces - [puzzle.solution]).each do |piece|
      expect(piece.value('color')).not_to eq(answer)
    end
  end

  it 'sets unique solution terms' do
    # @type [Class<Logigram::Base>]
    klass = Class.new(Logigram::Base) do
      constrain 'color', ['red', 'green']
    end
    # This should succeed because the solution term can always be unique, even
    # though the other two terms will always be the same. For example, if the
    # solution piece is red, the other pieces will both be green.
    puzzle = klass.new(['pencil', 'pen', 'crayon'])
    solution = puzzle.solution_value
    matches = puzzle.pieces.select { |piece| piece.value('color') == solution }
    expect(matches).to be_one
  end

  it 'raises errors for insufficient constraint values' do
    klass = Class.new(Logigram::Base) do
      constrain 'color', ['red']
    end
    expect {
      # This should fail because the solution term requires a unique value, but
      # all three pieces will be red.
      klass.new(['pencil', 'pen', 'crayon'])
    }.to raise_error(RuntimeError)
  end
end
