module Servers
  class ChatServer < BaseServer
    def initialize
      @name = :chat
      @rooms = Hash.new { |k, v| k[v] = [] }
      subscribe(SocketServer::SOCKET_CLOSE, :on_socket_close)
    end

    def handle(user_id, message)
      case message['action']
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

    def join(user_id, room_id)
      @rooms[room_id] << user_id
    end

    def leave(user_id, room_id)
      if room = @rooms[room_id]
        room.delete(user_id)
        @rooms.delete(room_id) if room.size == 0
      end
    end

    def say(user_id, room_id, text)
      message = Message.new(user_id: user_id, room_id: room_id, text: text)

      @rooms[room_id].each do |user_id|
        send(user_id, :say, message.to_data)
      end
    end

    # Notifications
    def on_socket_close(pattern, user_id)
      @rooms.values.each do |room_id|
        leave(user_id, room_id)
      end
    end
  end
end
