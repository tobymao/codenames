module Handlers
  class Connection
    include Notifier
    API_URL = "ws://#{`window.location.hostname`}:8090/api"

    def initialize
      connect
    end

    def connect
      puts "Websocket connecting..."
      @socket = Browser::Socket.new(API_URL) do |ws|
        ws.on(:open) { |e| on_open(e) }
        ws.on(:message) { |e| on_message(e) }
        ws.on(:close) { |e| on_close(e) }
        ws.on(:error) { |e| on_error(e) }
      end
    end

    def ping
      after(60) do
        send(:ping, nil, nil)
        ping if @connected
      end
    end

    def on_open(e)
      puts "Websocket open"
      @connected = true
      ping
      publish(self, :update, "Connected To Server")
    end

    def on_message(e)
      puts "Received message #{e.data}"
      message = JSON.parse(e.data)
      publish(self, message[:kind], message)
    end

    def on_close(e)
      puts "Websocket closed"
      @connected = false
      Stores::USERS_STORE.reset
    end

    def on_error(e)
      puts "Websocket error"
      publish(self, :update, "Not Connected... Error")
      @socket.close
    end

    def send(kind, action, data)
      return unless @socket.state == 'open'
      message = { kind: kind, action: action, data: data }
        .delete_if { |_, v| v.nil? }
        .to_json
      puts "Sending to server #{message}"
      @socket << message
    end
  end

  CONNECTION = Connection.new
end
