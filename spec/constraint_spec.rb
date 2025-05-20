RSpec.describe Logigram::Constraint do
  it 'validates constraint values' do
    constraint = Logigram::Constraint.new('color', %w[red green blue])
    expect { constraint.subject 'gray' }.to raise_error(ArgumentError)
    expect { constraint.predicate 'gray' }.to raise_error(ArgumentError)
    expect { constraint.negative 'gray' }.to raise_error(ArgumentError)
  end

  it 'sets a reserve' do
    constraint = Logigram::Constraint.new('color', %w[red green blue], reserve: 'blue')
    expect(constraint.reserves).to eq(['blue'])
  end

  it 'sets an array of reserves' do
    constraint = Logigram::Constraint.new('color', %w[red green blue], reserve: %w[red green])
    expect(constraint.reserves).to eq(%w[red green])
  end

  it 'throws an error for invalid reserves' do
    expect do
      Logigram::Constraint.new('color', %w[red blue], reserve: 'green')
    end.to raise_error(ArgumentError)
  end

  describe '#inspect' do
    it 'includes its name' do
      constraint = Logigram::Constraint.new('constraint_name', [1, 2, 3])
      expect(constraint.inspect).to include('constraint_name')
    end
  end

  describe '#descriptor' do
    it 'returns a default descriptor for a value' do
      constraint = Logigram::Constraint.new('color', %w[red blue])
      expect(constraint.descriptor('red')).to eq('red')
    end

    it 'returns a custom descriptor for a value' do
      constraint = Logigram::Constraint.new('hair', %w[red brown],
                                            formatter: Logigram::Formatter.new(descriptor: '%<value>s-haired'))
      expect(constraint.descriptor('red')).to eq('red-haired')
    end
  end

  describe '#verb' do
    let(:formatter) { Logigram::Formatter.new(verb: ['looks', 'look', 'does not look', 'do not look']) }
    let(:constraint) { Logigram::Constraint.new('color', %w[red blue], formatter: formatter) }

    it 'returns a single affirmative verb' do
      expect(constraint.verb(1, true)).to eq('looks')
    end

    it 'returns a single negative verb' do
      expect(constraint.verb(1, false)).to eq('does not look')
    end

    it 'returns a plural affirmative verb' do
      expect(constraint.verb(2, true)).to eq('look')
    end

    it 'returns a plural negative verb' do
      expect(constraint.verb(2, false)).to eq('do not look')
    end
  end
end
