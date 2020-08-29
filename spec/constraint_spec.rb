RSpec.describe Logigram::Constraint do
  it 'validates constraint values' do
    constraint = Logigram::Constraint.new('color', ['red', 'green', 'blue'])
    expect { constraint.subject 'gray' }.to raise_error(ArgumentError)
    expect { constraint.predicate 'gray' }.to raise_error(ArgumentError)
    expect { constraint.negative 'gray' }.to raise_error(ArgumentError)
  end
end
