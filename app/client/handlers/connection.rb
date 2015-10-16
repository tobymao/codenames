module Handlers
  class Connection
    API_URL = "ws://#{`window.location.hostname`}:8080/api"

    def initialize
      @handlers = Hash.new { |h, k| h[k] = [] }

      @socket = Browser::Socket.new(API_URL) do |ws|
        ws.on(:open) { |e| on_open(e) }
        ws.on(:message) { |e| on_message(e) }
        ws.on(:close) { |e| on_close(e) }
        ws.on(:error) { |e| on_error(e) }
      end
    end

    def on_open(e)
      puts "Websocket open"
      send(:game, :new, nil)
    end

    def on_message(e)
      puts "Received message #{e.data}"
      obj = JSON.parse(e.data)
      DefaultNotifier.publish(self, obj[:kind], e.data)
    end

    def on_close(e)
      puts "Websocket closed"
    end

    def on_error(e)
      puts "Websocket error"
      @socket.close
    end

    def send(kind, action, data)
      msg = { kind: kind, action: action, data: data }.to_json
      puts "Sending to server #{msg}"
      @socket << msg
    end
  end
end
