module Servers
  class GameServer
    include Celluloid
    include Celluloid::Notifications
    include Celluloid::Internals::Logger

    def initialize()
      @user_game = {}
      @game_users = Hash.new { [] }

      subscribe(SocketServer::SOCKET_CLOSE, :on_socket_close)
    end

    def handle(uid, message)
      case message['action']
      when 'new'
        new_game(uid)
      when 'join'
        join_game(uid, message['data']['game_id'])
      when 'move'
      else
      end
    end

    def new_game(uid)
      game = Models::Game.new
      game.team_a << uid
      @user_game[uid] = game
      @game_users[game.id] << uid

      Actor[:socket_server].async.send(uid, { kind: 'game', action: 'new', data: game.data }.to_json)
    end

    def join_game(uid, game_id)
    end

    # To Do: Clean up user...
    def on_socket_close(pattern, uid)
      game = @user_game[uid]
      info "socket closed #{uid}"
    end
  end
end
