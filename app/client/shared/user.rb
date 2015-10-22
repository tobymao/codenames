class User
  attr_reader :id, :name

  def self.from_data(data)
    new(
      id: data[:id],
      name: data[:name],
    )
  end

  def to_data
    {
      id: @id,
      name: @name,
    }
  end


  def initialize(id:, name:)
    @id = id
    @name = name
  end

  def ==(other)
    @id == other.id
  end
end
