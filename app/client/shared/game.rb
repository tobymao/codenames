class Game
  @@cards =
    begin
      path = File.expand_path('../../../../assets/cards.json', __FILE__)
      file = File.read(path)
      JSON.parse(file)
    end if RUBY_ENGINE != 'opal'

  attr_reader :id, :first, :creator, :name, :team_a, :team_b, :current, :grid, :winner, :clue, :count, :remaining, :watchers
  attr_accessor :started

  def self.from_data(data)
    new(
      id: data[:id],
      first: data[:first],
      creator: data[:creator],
      name: data[:name],
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
      started: data[:started],
    )
  end

  def to_data
    {
      id: @id,
      first: @first,
      creator: @creator,
      name: @name,
      team_a: @team_a.to_data,
      team_b: @team_b.to_data,
      current: @current,
      grid: @grid.map { |row| row.map(&:to_data) },
      winner: @winner,
      clue: @clue,
      count: @count,
      remaining: @remaining,
      started: @started,
    }.delete_if { |_, v| v.nil? }
  end

  def to_info
    GameInfo.new(id: @id, team_a: @team_a, team_b: @team_b, creator: @creator, name: @name)
  end

  def initialize(id:, first:, creator:, name:, team_a: nil, team_b: nil, current: nil, grid: nil, winner: nil, clue: nil, count: nil, remaining: nil, started: nil)
    @watchers = []

    @id = id
    @first = first
    @clue = clue
    @count = count
    @creator = creator
    @name = name
    @winner = winner

    @remaining = remaining || 0
    @started = started || false
    @team_a = team_a || Team.new(color: first)
    @team_b = team_b || Team.new(color: first == :red ? :blue : :red)
    @current = current || @first
    @grid = grid || setup_grid
  end

  def join_team(user_id, color, master)
    return false if @started

    leave(user_id, false)
    team = team_for_color(color)

    if master
      return false if team.master
      team.master = user_id
    else
      team.members << user_id
    end

    true
  end

  def leave(user_id, delete_watchers=true)
    @watchers.delete(user_id) if delete_watchers
    @team_a.members.delete(user_id)
    @team_b.members.delete(user_id)
    @team_a.master = nil if @team_a.master == user_id
    @team_b.master = nil if @team_b.master == user_id
  end

  def give_clue(clue, count)
    return false unless @started

    @clue = clue
    @count = count
    @remaining =
      if ['Infinity', '0'].include?(count)
        left(@current)
      else
        [count.to_i + 1, left(@current)].min
      end

    true
  end

  def pass
    return false unless @started

    @current = other
    @count = nil
    @clue = nil
    @remaining = 0

    true
  end

  def choose_word(value)
    return false unless @started

    words = @grid.flatten
    word = words.find { |w| w.value == value }
    return false if word.chosen?

    word.choose
    @remaining -= 1

    end_game(other) if word.assasin?

    if !word.color?(@current) || @remaining <= 0
      pass
    end

    end_game(:red) if words.select(&:red?).all?(&:chosen?)
    end_game(:blue) if words.select(&:blue?).all?(&:chosen?)

    true
  end

  def empty?
    @team_a.members.size == 0 &&
      @team_b.members.size == 0 &&
      !@team_a.master &&
      !@team_b.master &&
      !@watchers.include?(@creator)
  end

  def master?(user_id)
    @team_a.master == user_id || @team_b.master == user_id
  end

  def team_for_color(color)
    color == @team_a.color ?  @team_a : @team_b
  end

  def active_member?(user_id)
    team_for_color(@current).members.include?(user_id)
  end

  def active_master?(user_id)
    team_for_color(@current).master == user_id
  end

  def solo_master?(user_id)
    master?(user_id) && !(@team_a.master && @team_b.master)
  end

  def other
    @current == :red ? :blue : :red
  end

  private
  def left(color)
    @grid.flatten.select { |w| w.color?(color) && !w.chosen }.size
  end

  def setup_grid
    second = @first == :red ? :blue : :red

    pool = [:assasin]
    7.times { pool << :neutral }
    8.times { pool << second }
    9.times { pool << @first }

    matrix = [[], [], [] ,[] ,[]]

    @@cards.sample(25).each_with_index do |card, index|
      random_index = rand(pool.length)
      matrix[index / 5] << Word.new(card.sample(1).first, pool.delete_at(random_index), false)
    end

    matrix
  end

  def end_game(winner)
    @winner = winner
  end
end
