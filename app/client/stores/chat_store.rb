require 'handlers/notifier'
require 'handlers/connection'

module Stores
  class ChatStore
    include Handlers::Notifier

    attr_reader :users, :messages

    def initialize
      @users = Hash.new { |k, v| k[v] = [] }
      @messages = Hash.new { |k, v| k[v] = [] }
      Handlers::CONNECTION.subscribe(self, :chat, :on_update)
    end

    def all(room_id)
      Handlers::CONNECTION.send(:chat, :all, room_id)
    end

    def say(room_id, message)
      data = { room_id: room_id, text: message}
      Handlers::CONNECTION.send(:chat, :say, data)
    end

    def join(room_id)
      Handlers::CONNECTION.send(:chat, :join, room_id)
    end

    def leave(room_id)
      @users.delete(room_id)
      @messages.delete(room_id)
      Handlers::CONNECTION.send(:chat, :leave, room_id)
    end

    private
    def on_update(sender, message)
      case message[:action]
      when :all
        user_ids = message[:data][:user_ids]
        room_id = message[:data][:room_id]
        on_all(user_ids, room_id)
      when :join
        user_id = message[:data][:user_id]
        room_id = message[:data][:room_id]
        on_join(user_id, room_id)
      when :leave
        user_id = message[:data][:user_id]
        room_id = message[:data][:room_id]
        on_leave(user_id, room_id)
      when :say
        on_say(message[:data])
      else
      end
    end

    def on_all(user_ids, room_id)
      @users[room_id] += user_ids
      publish(self, :update, nil)
    end

    def on_join(user_id, room_id)
      @users[room_id] += [user_id]
      publish(self, :update, nil)
    end

    def on_leave(user_id, room_id)
      @users[room_id] -= [user_id]
      publish(self, :update, nil)
    end

    def on_say(data)
      message = Message.from_data(data)
      @messages[message.room_id] += [message]
      # Copy hash if you ever need to render the rooms...
      publish(self, :update, nil)
    end
  end

  CHAT_STORE = ChatStore.new
end
