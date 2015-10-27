module Servers
  class ChatServer < BaseServer
    def initialize
      @name = :chat
      @rooms = Hash.new { |k, v| k[v] = [] }
      subscribe(SocketServer::SOCKET_CLOSE, :on_socket_close)
    end

    def handle(user_id, message)
      case message['action']
      when 'all'
        all(user_id, message['data'])
      when 'join'
        join(user_id, message['data'])
      when 'leave'
        leave(user_id, message['data'])
      when 'say'
        room_id = message['data']['room_id']
        text = message['data']['text']
        say(user_id, room_id, text)
      else
        error "GameServer received unknown action #{message['action']}"
      end
    end

    def all(user_id, room_id)
      return unless room = @rooms[room_id]
      data = { room_id: room_id, user_ids: room }
      send(user_id, :all, data)
    end

    def join(user_id, room_id)
      return unless room = @rooms[room_id]
      data = { room_id: room_id, user_id: user_id }
      send_room(room, :join, data)
      room << user_id
    end

    def leave(user_id, room_id)
      return unless room = @rooms[room_id]
      room.delete(user_id)
      if room.size == 0
        @rooms.delete(room_id)
      else
        data = { room_id: room_id, user_id: user_id }
        send_room(room, :leave, data)
      end
    end

    def say(user_id, room_id, text)
      return unless users = @rooms[room_id]
      message = Message.new(user_id: user_id, room_id: room_id, text: text)
      users.each do |user_id|
        send(user_id, :say, message.to_data)
      end
    end

    def send_room(room, action, data)
      room.each { |user_id| send(user_id, action, data) }
    end

    # Notifications
    def on_socket_close(pattern, user_id)
      @rooms.keys.each do |room_id|
        leave(user_id, room_id)
      end
    end
  end
end
