module Handlers
  class Connection
    include Notifier
    API_URL = "ws://#{`window.location.hostname`}:8080/api"

    def initialize
      @socket = Browser::Socket.new(API_URL) do |ws|
        ws.on(:open) { |e| on_open(e) }
        ws.on(:message) { |e| on_message(e) }
        ws.on(:close) { |e| on_close(e) }
        ws.on(:error) { |e| on_error(e) }
      end
    end

    def on_open(e)
      puts "Websocket open"
      send(:game, :all, nil)
    end

    def on_message(e)
      puts "Received message #{e.data}"
      message = JSON.parse(e.data)
      publish(self, message[:kind], message)
    end

    def on_close(e)
      puts "Websocket closed"
      # TODO: do a retry
    end

    def on_error(e)
      puts "Websocket error"
      @socket.close
    end

    def send(kind, action, data)
      message = { kind: kind, action: action, data: data }
        .delete_if { |_, v| v.nil? }
        .to_json
      puts "Sending to server #{message}"
      @socket << message
    end
  end

  CONNECTION = Connection.new
end
