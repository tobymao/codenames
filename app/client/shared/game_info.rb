class GameInfo
  attr_reader :id, :team_a, :team_b

  def self.from_data(data)
    new(
      id: data[:id],
      team_a: Team.from_data(data[:team_a]),
      team_b: Team.from_data(data[:team_b]),
    )
  end

  def to_data
    {
      id: @id,
      team_a: @team_a.to_data,
      team_b: @team_b.to_data,
    }.delete_if { |_, v| v.nil? }
  end

  def initialize(id:, team_a:, team_b:)
    @id = id
    @team_a = team_a
    @team_b = team_b
  end
end
