class GameInfo
  attr_reader :id, :creator, :name, :team_a, :team_b

  def self.from_data(data)
    new(
      id: data[:id],
      creator: data[:creator],
      name: data[:name],
      team_a: Team.from_data(data[:team_a]),
      team_b: Team.from_data(data[:team_b]),
    )
  end

  def to_data
    {
      id: @id,
      creator: @creator,
      name: @name,
      team_a: @team_a.to_data,
      team_b: @team_b.to_data,
    }.delete_if { |_, v| v.nil? }
  end

  def initialize(id:, creator:, name:, team_a:, team_b:)
    @id = id
    @creator = creator
    @name = name
    @team_a = team_a
    @team_b = team_b
  end
end
