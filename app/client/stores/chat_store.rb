require 'handlers/notifier'
require 'handlers/connection'

module Stores
  class ChatStore
    include Handlers::Notifier

    attr_reader :rooms

    def initialize
      @rooms = {}
      Handlers::CONNECTION.subscribe(self, :chat, :on_update)
    end

    def say(room_id, message)
      data = { room_id: room_id, text: message}
      Handlers::CONNECTION.send(:chat, :say, data)
    end

    def join(room_id)
      @rooms[room_id] = []
      Handlers::CONNECTION.send(:chat, :join, room_id)
    end

    def leave(room_id)
      @rooms.delete(room_id)
      Handlers::CONNECTION.send(:chat, :leave, room_id)
    end

    private
    def on_update(sender, message)
      case message[:action]
      when :say
        on_say(message[:data])
      else
      end
    end

    def on_say(data)
      message = Message.from_data(data)
      @rooms[message.room_id] += [message]
      # Copy hash if you ever need to render the rooms...
      publish(self, :update, nil)
    end
  end

  CHAT_STORE = ChatStore.new
end
