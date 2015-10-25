require 'handlers/notifier'
require 'handlers/connection'

module Stores
  class ChatStore
    include Handlers::Notifier

    attr_reader :main_messages, :game_messages

    def initialize
      @main_messages = []
      @game_messages = []
      Handlers::CONNECTION.subscribe(self, :chat, :on_update)
    end

    def say(room_id, message)
      data = { room_id: room_id, text: message}
      Handlers::CONNECTION.send(:chat, :say, data)
    end

    def join(room_id)
      Handlers::CONNECTION.send(:chat, :join, room_id)
    end

    private
    def on_update(sender, message)
      case message[:action]
      when :say
        on_say(message[:data])
      when :leave
        on_leave(message[:data])
      else
      end
    end

    def on_say(data)
      message = Message.from_data(data)

      if message.room_id == 'main'
        @main_messages += [message]
      else
        @game_messages += [message]
      end

      publish(self, :update, nil)
    end
  end

  CHAT_STORE = ChatStore.new
end
