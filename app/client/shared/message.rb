class Message
  attr_reader :user_id, :room_id, :text
  attr_accessor :user_name

  def self.from_data(data)
    new(
      user_id: data[:user_id],
      room_id: data[:room_id],
      text: data[:text],
    )
  end

  def to_data
    {
      user_id: @user_id,
      room_id: @room_id,
      text: @text,
    }.delete_if { |_, v| v.nil? }
  end

  def initialize(user_id:, room_id:, text:)
    @user_id = user_id
    @room_id = room_id
    @text = text
  end
end
