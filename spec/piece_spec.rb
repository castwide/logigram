# frozen_string_literal: true

RSpec.describe Logigram::Piece do
  describe '#name' do
    it 'sets names from objects' do
      object = Object.new
      piece = Logigram::Piece.new(object, [])
      expect(piece.name).to eq(object.to_s)
    end
  end

  describe '#property' do
    it 'returns properties by constraint' do
      constraint = Logigram::Constraint.new('constraint', ['one', 'two'])
      property = Logigram::Property.new(constraint, 'one')
      piece = Logigram::Piece.new('object', [property])
      expect(piece.property(constraint)).to eq(property)
    end

    it 'returns properties by constraint name' do
      constraint = Logigram::Constraint.new('constraint', ['one', 'two'])
      property = Logigram::Property.new(constraint, 'one')
      piece = Logigram::Piece.new('object', [property])
      expect(piece.property('constraint')).to eq(property)
    end
  end

  describe '#value' do
    it 'returns values by constraint' do
      constraint = Logigram::Constraint.new('constraint', ['one', 'two'])
      property = Logigram::Property.new(constraint, 'one')
      piece = Logigram::Piece.new('object', [property])
      expect(piece.value(constraint)).to eq('one')
    end

    it 'returns values by constraint name' do
      constraint = Logigram::Constraint.new('constraint', ['one', 'two'])
      property = Logigram::Property.new(constraint, 'one')
      piece = Logigram::Piece.new('object', [property])
      expect(piece.value('constraint')).to eq('one')
    end
  end
end
