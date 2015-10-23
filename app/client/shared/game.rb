class Game
  WORDS = %w(Acne Acre Addendum Advertise Aircraft Aisle Alligator Alphabetize America Ankle Apathy Applause Applesauce Application Archaeologist Aristocrat Arm Armada Asleep Astronaut Athlete Atlantis Aunt Avocado Acorn).freeze

  attr_reader :id, :first, :team_a, :team_b, :current, :grid, :winner, :clue, :count
  attr_accessor :watchers

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

  def initialize(id:, first:, team_a: nil, team_b: nil, current: nil, grid: nil, clue: nil, count: nil)
    @watchers = []

    @id = id
    @first = first
    @clue = clue
    @count = count || 0

    @team_a = team_a || Team.new(color: first)
    @team_b = team_b || Team.new(color: first == :red ? :blue : :red)
    @current = current || @first

    unless @grid = grid
      @grid = setup_grid if !@grid
    end
  end

  def join_team(user_id, color, master)
    @team_a.members.delete(user_id)
    @team_b.members.delete(user_id)
    @team_a.master = nil if @team_a.master == user_id
    @team_b.master = nil if @team_b.master == user_id

    team = team_for_color(color)

    if master
      team.master = user_id
    else
      team.members << user_id
    end
  end

  def master?(user_id)
    @team_a.master == user_id || @team_b.master == user_id
  end

  def team_for_color(color)
    color == @team_a.color.to_s ?  @team_a : @team_b
  end

  def give_clue(clue, count)
    @clue = clue
    @count = count
  end

  def end_turn
    @current = other
    @count = 0
  end

  def end_game(winner)
    @count = 0
    @winner = winner
  end

  def choose_word(value)
    words = @grid.flatten
    word = words.find { |w| w.value == value }
    return nil if word.chosen?

    word.choose
    @count -= 1

    if @current != word.owner || @count <= 0
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
