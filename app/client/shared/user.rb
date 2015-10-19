class User
  attr_reader :id, :name

  def initialize(id, name)
    @id = id
    @name = name
  end

  def ==(other)
    @id == other.id
  end
end
