RSpec.describe Logigram::Constraint do
  it 'validates constraint values' do
    constraint = Logigram::Constraint.new('color', ['red', 'green', 'blue'])
    expect { constraint.subject 'gray' }.to raise_error(ArgumentError)
    expect { constraint.predicate 'gray' }.to raise_error(ArgumentError)
    expect { constraint.negative 'gray' }.to raise_error(ArgumentError)
  end

  it 'sets subject phrases' do
    constraint = Logigram::Constraint.new('color', ['red', 'green', 'blue'], subject: 'the %{value} piece')
    expect(constraint.subject 'red').to eq('the red piece')
  end

  it 'sets predicate phrases' do
    constraint = Logigram::Constraint.new('color', ['red', 'green', 'blue'], subject: 'is %{value} in color')
    expect(constraint.subject 'red').to eq('is red in color')
  end

  it 'sets negative phrases' do
    constraint = Logigram::Constraint.new('color', ['red', 'green', 'blue'], subject: 'is a color other than %{value}')
    expect(constraint.subject 'red').to eq('is a color other than red')
  end

  it 'sets reserves' do
    constraint = Logigram::Constraint.new('color', ['red', 'green', 'blue'], reserve: 'blue')
    expect(constraint.reserves).to eq(['blue'])
  end

  it 'throws an error for invalid reserves' do
    expect {
      Logigram::Constraint.new('color', ['red', 'blue'], reserve: 'green')
    }.to raise_error(Logigram::Constraint::SelectionError)
  end
end
