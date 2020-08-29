RSpec.describe Logigram::Base do
  describe 'initialization' do
    it 'accepts constraints' do
      klass = Class.new(Logigram::Base) do
        constrain 'color', ['red', 'green', 'blue']
      end
      # @type [Logigram::Base]
      puzzle = klass.new(['dog', 'cat', 'pig'])
      expect(puzzle.terms).to eq(['color'])
      expect(puzzle.constraints['color'].values).to eq(['red', 'green', 'blue'])
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
  end
end
