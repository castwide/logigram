# frozen_string_literal: true

RSpec.describe Logigram::Challenge do
  let(:puzzle) do
    klass = Class.new(Logigram::Base) do
      constrain 'color', %w[red blue green]
      constrain 'size', %w[small medium large]
    end
    klass.new(%w[dog cat pig])
  end

  it 'generates clues' do
    challenge = Logigram::Challenge.new(puzzle)
    expect(challenge.clues).not_to be_empty
  end

  it 'excludes the solution predicate from the clues' do
    challenge = Logigram::Challenge.new(puzzle)
    strings = challenge.clues.map(&:to_s)
    expect(strings).not_to include("#{puzzle.solution} #{puzzle.solution.properties.map(&:predicate)}")
  end
end
