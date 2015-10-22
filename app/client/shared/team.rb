class Team
  attr_reader :color
  attr_accessor :master, :members

  def self.from_data(data)
    new(
      color: data[:color],
      master: data[:master],
      members: data[:members],
    )
  end

  def to_data
    {
      color: @color,
      master: @master,
      members: @members,
    }
  end

  def initialize(color:, master: nil, members: nil)
    @color = color
    @master = master
    @members = members || []
  end
end
