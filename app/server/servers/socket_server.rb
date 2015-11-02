module Servers
  class SocketServer
    include Celluloid
    include Celluloid::IO
    include Celluloid::Notifications
    include Celluloid::Internals::Logger

    SOCKET_CLOSE = :user_socket_close

    def initialize
      @user_id_socket = {}
      @socket_user_id = {}
    end

    def connect(socket)
      user_id = SecureRandom.uuid
      info "User connected #{user_id}"
      async.listen(user_id, socket)
      @user_id_socket[user_id] = socket
      @socket_user_id[socket] = user_id
    end

    def listen(user_id, socket)
      while message = JSON.parse(socket.read)
        receive(user_id, message)
      end
    rescue
      info "EOF #{user_id} disconnected"
      close(user_id, socket)
    end

    def receive(user_id, message)
      info "Recived message: #{message}"
      case message['kind']
      when 'game'
        Actor[:game_server].async.handle(user_id, message)
      when 'user'
        Actor[:user_server].async.handle(user_id, message)
      when 'chat'
        Actor[:chat_server].async.handle(user_id, message)
      when 'ping'
      else
        error "Unknown controller #{message}"
      end
    end

    def send_all(kind, action, data)
      @socket_user_id.values.each do |user_id|
        send(user_id, kind, action, data)
      end
    end

    def send(user_id, kind, action, data)
      if socket = @user_id_socket[user_id]
        message = { kind: kind, action: action, data: data }
        message.delete(:data) unless data
        socket << message.to_json
      else
        error "Tried sending to #{user_id} but socket is gone"
      end
    rescue
      info "Could not send message. #{user_id} disconnected"
      close(user_id, message)
    end

    def close(user_id, socket)
      @user_id_socket.delete(user_id)
      @socket_user_id.delete(socket)
      publish(SOCKET_CLOSE, user_id)
      socket.close
    end
  end
end
