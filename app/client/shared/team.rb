class Team
  attr_reader :color, :members
  attr_accessor :master

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
    }.delete_if { |_, v| v.nil? }
  end

  def initialize(color:, master: nil, members: nil)
    @color = color
    @master = master
    @members = members || []
  end
end
