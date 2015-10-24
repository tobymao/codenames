class Game
  @@cards =
    begin
      path = File.expand_path('../../../../assets/cards.json', __FILE__)
      file = File.read(path)
      JSON.parse(file)
    end if RUBY_ENGINE != 'opal'

  attr_reader :id, :first, :team_a, :team_b, :current, :grid, :winner, :clue, :count, :remaining, :watchers

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
      winner: data[:winner],
      clue: data[:clue],
      count: data[:count],
      remaining: data[:remaining],
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
      winner: @winner,
      clue: @clue,
      count: @count,
      remaining: @remaining,
    }
  end

  def initialize(id:, first:, team_a: nil, team_b: nil, current: nil, grid: nil, clue: nil, count: nil, remaining: nil)
    @watchers = []

    @id = id
    @first = first
    @clue = clue
    @count = count

    @remaining = remaining || 0
    @team_a = team_a || Team.new(color: first)
    @team_b = team_b || Team.new(color: first == :red ? :blue : :red)
    @current = current || @first
    @grid = grid || setup_grid
  end

  def join_team(user_id, color, master)
    leave(user_id, false)
    team = team_for_color(color)

    if master
      team.master = user_id
    else
      team.members << user_id
    end
  end

  def leave(user_id, all=true)
    @watchers.delete(user_id) if watchers
    @team_a.members.delete(user_id)
    @team_b.members.delete(user_id)
    @team_a.master = nil if @team_a.master == user_id
    @team_b.master = nil if @team_b.master == user_id
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
    @remaining =
      if ['Infinity', '0'].include?(count)
        left(@current)
      else
        [count.to_i + 1, left(@current)].min
      end
  end

  def pass
    @current = other
    @count = nil
    @clue = nil
    @remaining = 0
  end

  def end_game(winner)
    @winner = winner
  end

  def choose_word(value)
    words = @grid.flatten
    word = words.find { |w| w.value == value }
    return false if word.chosen?

    word.choose
    @remaining -= 1

    if !word.color?(@current) || @remaining <= 0
      pass
    end

    end_game(other) if word.assasin?
    end_game(:red) if words.select(&:red?).all?(&:chosen?)
    end_game(:blue) if words.select(&:blue?).all?(&:chosen?)

    true
  end

  private
  def other
    @current == :red ? :blue : :red
  end

  def left(color)
    @grid.flatten.select { |w| w.color?(color) && !w.chosen }.size
  end

  def setup_grid
    first = @first
    second = first == :red ? :blue : :red

    pool = [:assasin]
    7.times { pool << :neutral }
    8.times { pool << second }
    9.times { pool << first }

    matrix = [[], [], [] ,[] ,[]]

    @@cards.sample(25).each_with_index do |card, index|
      random_index = rand(pool.length)
      matrix[index / 5] << Word.new(card.sample(1).first, pool.delete_at(random_index), false)
    end

    matrix
  end
end
