module Servers
  class BaseServer
    include Celluloid
    include Celluloid::Notifications
    include Celluloid::Internals::Logger

    def initialize
      @name = nil
    end

    def handle(user_id, message)
      raise NotImplementedError
    end

    def send_all(action, data)
      raise unless @name
      Actor[:socket_server].async.send_all(@name, action, data)
    end

    def send(user_id, action, data)
      raise unless @name
      Actor[:socket_server].async.send(user_id, @name, action, data)
    end
  end
end
