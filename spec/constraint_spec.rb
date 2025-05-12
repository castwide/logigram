RSpec.describe Logigram::Constraint do
  it 'validates constraint values' do
    constraint = Logigram::Constraint.new('color', ['red', 'green', 'blue'])
    expect { constraint.subject 'gray' }.to raise_error(ArgumentError)
    expect { constraint.predicate 'gray' }.to raise_error(ArgumentError)
    expect { constraint.negative 'gray' }.to raise_error(ArgumentError)
  end

  it 'sets a reserve' do
    constraint = Logigram::Constraint.new('color', ['red', 'green', 'blue'], reserve: 'blue')
    expect(constraint.reserves).to eq(['blue'])
  end

  it 'sets an array of reserves' do
    constraint = Logigram::Constraint.new('color', ['red', 'green', 'blue'], reserve: ['red', 'green'])
    expect(constraint.reserves).to eq(['red', 'green'])
  end

  it 'throws an error for invalid reserves' do
    expect {
      Logigram::Constraint.new('color', ['red', 'blue'], reserve: 'green')
    }.to raise_error(ArgumentError)
  end
end
