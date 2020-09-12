RSpec.describe Logigram::Premise do
  it 'identifies its subject by name' do
    constraint = Logigram::Constraint.new('color', ['red', 'blue'])
    piece = Logigram::Piece.new('dog', {'color' => 'red'})
    premise = Logigram::Premise.new(piece, constraint, 'red')
    expect(premise.subject).to eq('dog')
    expect(premise.specific?).to be(true)
  end

  it 'identifies its subject by constraint' do
    constraint = Logigram::Constraint.new('color', ['red', 'blue'])
    identifier = Logigram::Constraint.new('size', ['small', 'large'])
    piece = Logigram::Piece.new('dog', {'color' => 'red', 'size' => 'small'})
    premise = Logigram::Premise.new(piece, constraint, 'red', identifier)
    expect(premise.subject).to eq('the small thing')
    expect(premise.specific?).to be(false)
  end

  it 'reports affirmative' do
    constraint = Logigram::Constraint.new('color', ['red', 'blue'])
    piece = Logigram::Piece.new('dog', {'color' => 'red'})
    premise = Logigram::Premise.new(piece, constraint, 'red')
    expect(premise).to be_affirmative
  end

  it 'reports negative' do
    constraint = Logigram::Constraint.new('color', ['red', 'blue'])
    piece = Logigram::Piece.new('dog', {'color' => 'red'})
    premise = Logigram::Premise.new(piece, constraint, 'blue')
    expect(premise).to be_negative
  end

  it 'uses predicate for affirmative text' do
    constraint = Logigram::Constraint.new('color', ['red', 'blue'], predicate: 'affirm')
    piece = Logigram::Piece.new('dog', {'color' => 'red'})
    premise = Logigram::Premise.new(piece, constraint, 'red')
    expect(premise.text).to eq('dog affirm')
  end

  it 'uses negative for negative text' do
    constraint = Logigram::Constraint.new('color', ['red', 'blue'], negative: 'negate')
    piece = Logigram::Piece.new('dog', {'color' => 'red'})
    premise = Logigram::Premise.new(piece, constraint, 'blue')
    expect(premise.text).to eq('dog negate')
  end
end
