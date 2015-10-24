class Word
  attr_reader :value, :color, :chosen

  def self.from_data(data)
    new(
      data[:value],
      data[:color],
      data[:chosen],
    )
  end

  def to_data
    {
      value: @value,
      color: @color,
      chosen: @chosen,
    }.delete_if { |_, v| v.nil? }
  end

  def initialize(value, color, chosen=false)
    @value = value
    @color = color
    @chosen = chosen
  end

  def color?(color)
    @color == color
  end

  def choose
    @chosen = true
  end

  def chosen?
    @chosen
  end

  def red?
    @color == :red
  end

  def blue?
    @color == :blue
  end

  def assasin?
    @color == :assasin
  end

  def neutral?
    @color == :neutral
  end
end
