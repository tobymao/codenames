class Game
  WORDS = %w(Acne Acre Addendum Advertise Aircraft Aisle Alligator Alphabetize America Ankle Apathy Applause Applesauce Application Archaeologist Aristocrat Arm Armada Asleep Astronaut Athlete Atlantis Aunt Avocado Acorn).freeze

  attr_reader :id, :first, :current, :grid, :winner, :team_a, :team_b
  attr_accessor :team_a, :team_b

  def self.from_data(data)
    new(
      id: data[:id],
      first: data[:first],
      team_a: Team.from_data(data[:team_a]),
      team_b: Team.from_data(data[:team_b]),
      current: data[:current],
      grid: data[:grid].map do |row|
        row.map { |word| Word.from_data(word) }
      end,
    )
  end

  def to_data
    {
      id: @id,
      first: @first,
      team_a: @team_a.to_data,
      team_b: @team_b.to_data,
      current: @current,
      grid: @grid.map { |row| row.map(&:to_data) },
    }
  end

  def initialize(id:, first:, team_a: nil, team_b: nil, current: nil, grid: nil)
    @clues = 0

    @id = id
    @first = first

    @team_a = team_a || Team.new(color: first)
    @team_b = team_b || Team.new(color: first == :red ? :blue : :red)
    @current = current || @first

    unless @grid = grid
      @grid = setup_grid if !@grid
    end
  end

  def team_for_color(color)
    @team_a if color == @team_a.color
    @team_b if color == @team_b.color
  end

  def give_clue(clue, count)
    @clues = count
  end

  def end_turn
    @current = other
    @clues = 0
  end

  def end_game(winner)
    @clues = 0
    @winner = winner
  end

  def choose_word(value)
    words = @grid.flatten
    word = words.find { |w| w.value == value }
    return nil if word.chosen?

    word.choose
    @clues -= 1

    if @current != word.owner || @clues <= 0
      end_turn
    end

    end_game(other) if word.assasin?
    end_game(:red) if words.select(&:red?).all?(&:chosen?)
    end_game(:blue) if words.select(&:blue?).all?(&:chosen?)

    word
  end

  private
  def other
    @current == :red ? :blue : :red
  end

  def setup_grid
    first = @first
    second = first == :red ? :blue : :red

    pool = [:assasin]
    7.times { pool << :neutral }
    8.times { pool << first }
    9.times { pool << second }

    matrix = [[], [], [] ,[] ,[]]

    WORDS.sample(25).each_with_index do |word, index|
      random_index = rand(pool.length)
      matrix[index / 5] << Word.new(word, pool.delete_at(random_index), false)
    end

    matrix
  end
end
