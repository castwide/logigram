require 'ostruct'

RSpec.describe Logigram::Piece do
  it 'sets names from objects' do
    object = Object.new
    piece = Logigram::Piece.new(object, {})
    expect(piece.name).to eq(object.to_s)
  end

  it 'accepts explicit names' do
    object = Object.new
    piece = Logigram::Piece.new(object, {}, name: 'Bob')
    expect(piece.name).to eq('Bob')
  end
end
