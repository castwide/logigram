RSpec.describe Logigram::Formatter do
  it 'has a default singular subject' do
    expect(Logigram::Formatter::DEFAULT.subject('red')).to eq('the red thing')
  end

  it 'has a default plural subject' do
    expect(Logigram::Formatter::DEFAULT.subject('red', 2)).to eq('the red things')
  end

  it 'has a default predicate' do
    expect(Logigram::Formatter::DEFAULT.predicate('red')).to eq('is red')
  end

  it 'has a default negative' do
    expect(Logigram::Formatter::DEFAULT.negative('red')).to eq('is not red')
  end

  it 'sets a subject' do
    formatter = Logigram::Formatter.new(subject: 'the %{value}-haired person')
    expect(formatter.subject('red')).to eq('the red-haired person')
  end

  it 'sets a default plural subject' do
    formatter = Logigram::Formatter.new(subject: 'the %{value}-haired person')
    expect(formatter.subject('red', 2)).to eq('the red-haired persons')
  end

  it 'sets a custom plural subject' do
    formatter = Logigram::Formatter.new(plural: 'the %{value}-haired people')
    expect(formatter.subject('red', 2)).to eq('the red-haired people')
  end

  it 'sets a verb' do
    formatter = Logigram::Formatter.new(verb: :have)
    expect(formatter.predicate('candy')).to eq('has candy')
  end

  it 'sets a descriptor' do
    formatter = Logigram::Formatter.new(verb: :have, descriptor: '%{value} in it')
    expect(formatter.predicate('candy')).to eq('has candy in it')
    expect(formatter.negative('candy')).to eq('does not have candy in it')
  end
end
