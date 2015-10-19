class Word
  attr_reader :value, :owner, :chosen

  def self.from_data(data)
    new(
      data[:value],
      data[:owner],
      data[:chosen],
    )
  end

  def to_data
    {
      value: @value,
      owner: @owner,
      chosen: @chosen,
    }.delete_if { |_, v| v.nil? }
  end

  def initialize(value, owner, chosen=false)
    @value = value
    @owner = owner
    @chosen = chosen
  end

  def choose
    @chosen = true
  end

  def chosen?
    @chosen
  end

  def red?
    @owner == :red
  end

  def blue?
    @owner == :blue
  end

  def assasin?
    @owner == :assasin
  end

  def neutral?
    @owner == :neutral
  end
end
