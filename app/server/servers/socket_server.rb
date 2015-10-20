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
      message = JSON.parse(socket.read)
      user_id = message['user_id']
      async.listen(user_id, socket)
      info "User connected #{user_id}"

      @user_id_socket[user_id] = socket
      @socket_user_id[socket] = user_id
      async.listen(user_id, socket)
    end

    def listen(user_id, socket)
      while message = JSON.parse(socket.read)
        receive(user_id, message)
      end
    rescue EOFError, IOError
      info "EOF Client disconnected"
      close(user_id, socket)
    end

    def receive(user_id, message)
      case message['kind']
      when 'game'
        info "Recived game message: #{message}"
        Actor[:game_server].async.handle(user_id, message)
      when 'chat'
        info "Chat Controller"
      else
        info "Unknown controller #{message}"
      end
    end

    def send_all(message)
      @socket_user_id.values.each { |user_id| send(user_id, message) }
    end

    def send(user_id, message)
      info "Sending message #{message}"
      socket = @user_id_socket[user_id]
      socket << message
    rescue Reel::SocketError
      info "Could not send message. Client disconnected"
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
