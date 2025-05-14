# frozen_string_literal: true

RSpec.describe Logigram::Generator::All do
  let(:puzzle) do
    klass = Class.new(Logigram::Base) do
      constrain 'color', %w[red blue green]
      constrain 'size', %w[small medium large]
    end
    klass.new(%w[dog cat pig])
  end

  it 'generates premises' do
    generator = Logigram::Generator::All.new(puzzle)
    expect(generator.premises).not_to be_empty
  end
end
