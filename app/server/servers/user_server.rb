module Servers
  class UserServer < BaseServer
    def initialize
      @name = :user
      @users = {}
      subscribe(SocketServer::SOCKET_CLOSE, :on_socket_close)
    end

    def handle(user_id, message)
      case message['action']
      when 'login'
        login(user_id, message['data'])
      when 'all'
        all(user_id)
      else
      end
    end

    def login(user_id, name)
      user = User.new(id: user_id, name: name)
      @users[user.id] = user
      data = user.to_data
      send(user_id, :authenticate, data)
      send_all(:login, data)
    end

    def all(user_id)
      users = {}
      @users.each { |id, user| users[id] = user.to_data }
      send(user_id, :all, users)
    end

    # Notifications
    def on_socket_close(pattern, user_id)
      @users.delete(user_id)
      send_all(:leave, user_id)
    end
  end
end
