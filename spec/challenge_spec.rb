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

  it 'generates easy clues' do
    challenge = Logigram::Challenge.new(puzzle, difficulty: :easy)
    expect(challenge.clues.length).to eq(4)
    expect(challenge.clues.all?(&:affirmative?)).to be(true)
  end

  it 'generates hard clues' do
    challenge = Logigram::Challenge.new(puzzle, difficulty: :hard)
    expect(challenge.clues.select(&:affirmative?).length).to eq(2)
  end

  it 'supports multiple terms' do
    klass = Class.new(Logigram::Base) do
      constrain 'color', %w[red green blue]
      constrain 'size', %w[small medium large]
      constrain 'height', %w[short average tall]
    end
    # @type [Logigram::Base]
    puzzle = klass.new(%w[dog cat mouse], determinants: %w[color size])
    %i[easy medium hard].each do |diff|
      expect { Logigram::Challenge.new(puzzle, difficulty: diff) }.not_to raise_error
    end
  end

  it 'supports duplicate values' do
    klass = Class.new(Logigram::Base) do
      constrain 'color', %w[red green], unique: false
    end
    # @type [Logigram::Base]
    puzzle = klass.new(%w[pencil pen crayon])
    answer = puzzle.solution.value('color')
    (puzzle.pieces - [puzzle.solution]).each do |piece|
      expect(piece.value('color')).not_to eq(answer)
    end
    %i[easy medium hard].each do |diff|
      expect { Logigram::Challenge.new(puzzle, difficulty: diff) }.not_to raise_error
    end
  end

  it 'supports multiple duplicate determinants' do
    con1 = Logigram::Constraint.new('color', %w[blue red], unique: false)
    con2 = Logigram::Constraint.new('size', %w[small large], unique: false)
    con3 = Logigram::Constraint.new('age', %w[old new], unique: false)
    puzzle = Logigram::Puzzle.new(constraints: [con1, con2, con3], objects: %w[shirt hat socks pants],
                                  determinants: [con1, con2])
    %i[easy medium hard].each do |diff|
      expect { Logigram::Challenge.new(puzzle, difficulty: diff) }.not_to raise_error
    end
  end
end
