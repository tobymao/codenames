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
      msg = JSON.parse(socket.read)
      msg['user_id']
      async.listen(1, socket)
    end

    def listen(uid, socket)
      while msg = JSON.parse(socket.read)
        receive(uid, msg)
      end
    rescue EOFError, IOError
      info "EOF Client disconnected"
      close(uid, socket)
    end

    def receive(uid, msg)
      case msg['kind']
      when 'game'
        info "Recived game msg: #{msg}"
        Actor[:game_server].async.handle(uid, msg)
      when 'chat'
        info "Chat Controller"
      else
        info "Unknown controller #{msg}"
      end
    end

    def send_all(msg)
      @socket_uid.values.each { |uid| send(uid, msg) }
    end

    def send(uid, msg)
      info "Sending msg #{msg}"
      socket = @uid_socket[uid]
      socket << msg
    rescue Reel::SocketError
      info "Could not send msg. Client disconnected"
      close(uid, msg)
    end

    def close(uid, socket)
      @uid_socket.delete(uid)
      @socket_uid.delete(socket)
      publish(SOCKET_CLOSE, uid)
      socket.close
    end
  end
end
