module Servers
  class SocketServer
    include Celluloid
    include Celluloid::IO
    include Celluloid::Notifications
    include Celluloid::Internals::Logger

    SOCKET_CLOSE = :user_socket_close

    def initialize
      @uid_socket = {}
      @socket_uid = {}
    end

    def connect(socket)
      info "User connected"
      @uid_socket[1] = socket
      @socket_uid[socket] = 1
      async.listen(1, socket)
    end

    def login(socket)
      message = JSON.parse(socket.read)
      message['user_id']
      async.listen(1, socket)
    end

    def listen(uid, socket)
      while message = JSON.parse(socket.read)
        receive(uid, message)
      end
    rescue EOFError, IOError
      info "EOF Client disconnected"
      close(uid, socket)
    end

    def receive(uid, message)
      case message['kind']
      when 'game'
        info "Recived game message: #{message}"
        Actor[:game_server].async.handle(uid, message)
      when 'chat'
        info "Chat Controller"
      else
        info "Unknown controller #{message}"
      end
    end

    def send_all(message)
      @socket_uid.values.each { |uid| send(uid, message) }
    end

    def send(uid, message)
      info "Sending message #{message}"
      socket = @uid_socket[uid]
      socket << message
    rescue Reel::SocketError
      info "Could not send message. Client disconnected"
      close(uid, message)
    end

    def close(uid, socket)
      @uid_socket.delete(uid)
      @socket_uid.delete(socket)
      publish(SOCKET_CLOSE, uid)
      socket.close
    end
  end
end
