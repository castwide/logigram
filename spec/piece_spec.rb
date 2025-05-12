# frozen_string_literal: true

RSpec.describe Logigram::Piece do
  it 'sets names from objects' do
    object = Object.new
    piece = Logigram::Piece.new(object, [])
    expect(piece.name).to eq(object.to_s)
  end
end
