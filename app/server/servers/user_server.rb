module Servers
  class UserServer
    include Celluloid
    include Celluloid::Notifications
    include Celluloid::Internals::Logger

    def initialize()
      @users = {}
      subscribe(SocketServer::SOCKET_CLOSE, :on_socket_close)
    end

    def handle(user_id, message)
      case message['action']
      when 'login'
        login(user_id, message['data'])
      when 'all'
        all_users(user_id)
      else
      end
    end

    def login(user_id, name)
      if @users[user_id]
        data = { kind: 'user', action: 'error', data: "name in use" }
        Actor[:socket_server].async.send(user_id, data.to_json)
      else
        user = User.new(id: user_id, name: name)
        @users[user.id] = user
        data = { kind: 'user', action: 'authenticate', data: user.to_data }
        Actor[:socket_server].async.send(user_id, data.to_json)
        general = { kind: 'user', action: 'login', data: user.to_data }
        Actor[:socket_server].async.send_all(general.to_json)
      end
    end

    def all_users(user_id)
      users = {}
      @users.each { |id, user| users[id] = user.to_data }
      data = { kind: 'user', action: 'all', data: users }
      Actor[:socket_server].async.send(user_id, data.to_json)
    end

    # To Do: Clean up user...
    def on_socket_close(pattern, user_id)
      info "socket closed #{user_id}"
    end
  end
end
