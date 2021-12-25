RSpec.describe Logigram::Statistics do
  it 'counts term values' do
    # @type [Class<Logigram::Base>]
    klass = Class.new(Logigram::Base) do
      constrain 'color', ['red', 'green'], reserve: 'red'
    end
    puzzle = klass.new(['pencil', 'pen', 'crayon'])
    statistics = Logigram::Statistics.new(puzzle)
    expect(statistics.statements).to eq(['1 thing is red', '2 things are green'])
  end
end
