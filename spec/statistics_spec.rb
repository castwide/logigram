RSpec.describe Logigram::Statistics do
  it 'counts term values' do
    # @type [Class<Logigram::Base>]
    klass = Class.new(Logigram::Base) do
      constrain 'color', ['red', 'green'], reserve: 'red', unique: false
    end
    puzzle = klass.new(['pencil', 'pen', 'crayon'])
    statistics = Logigram::Statistics.new(puzzle)
    expect(statistics.statements.length).to be(2)
    expect(statistics.statements).to include('1 thing is red')
    expect(statistics.statements).to include('2 things are green')
  end
end
