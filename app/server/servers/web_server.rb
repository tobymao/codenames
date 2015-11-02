module Servers
  class WebServer < Reel::Server::HTTP
    include Celluloid::Internals::Logger

    def initialize(host = "0.0.0.0", port = 8090)
      info "Server started on #{host}:#{port}"
      super(host, port, &method(:on_connection))
    end

    def on_connection(connection)
      while request = connection.request
        time = Time.now

        if request.websocket?
          # Pass off control to socket server.
          connection.detach
          route_socket(request.websocket)
        else
          Routers::HTTPRouter.route(connection, request)
        end

        info "Request #{request.url} finished in #{Time.now - time}"
        return
      end
    end

    def route_socket(socket)
      case socket.url
      when '/api'
        Actor[:socket_server].async.connect(socket)
      else
        info "Received invalid WebSocket request for: #{socket.url}"
        socket.close
      end
    end
  end
end
