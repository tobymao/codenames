module Servers
  class GameServer
    include Celluloid
    include Celluloid::Notifications
    include Celluloid::Internals::Logger

    def initialize()
      @games = {}
      subscribe(SocketServer::SOCKET_CLOSE, :on_socket_close)
    end

    def handle(user_id, message)
      case message['action']
      when 'all'
        all_games(user_id)
      when 'new'
        new_game(user_id)
      when 'join'
        join_game(user_id, message['data']['game_id'])
      when 'choose'
        choose_word(user_id, message['data']['game_id'], message['data']['value'])
      else
      end
    end

    def all_games(user_id)
      data = { kind: 'game', action: 'all', data: { game_ids: @games.keys } }
      Actor[:socket_server].async.send(user_id, data.to_json)
    end

    def new_game(user_id)
      game = Game.new(id: SecureRandom.uuid, first: Random.rand(2) == 0 ? :red : :blue)
      game.team_a[:members] << user_id
      @games[game.id] = game

      send_join_game(user_id, game)

      data = { kind: 'game', action: 'new', data: { game_id: game.id } }
      Actor[:socket_server].async.send_all(data.to_json)
    end

    def choose_word(user_id, game_id, value)
      game = @games[game_id]
      word = game.choose_word(value)

      users = game.team_a[:members] + game.team_b[:members]

      users.each do |user|
        next if user_id == user
        data = { kind: 'game', action: 'choose', data: { value: value } }
        Actor[:socket_server].async.send(user, data.to_json)
      end
    end

    def join_game(user_id, game_id)
      game = @games[game_id]
      game.team_b[:members] << user_id
      send_join_game(user_id, game)
    end

    def send_join_game(user_id, game)
      data = { kind: 'game', action: 'join', data: game.to_data }
      Actor[:socket_server].async.send(user_id, data.to_json)
    end

    # To Do: Clean up user...
    def on_socket_close(pattern, user_id)
      info "socket closed #{user_id}"
    end
  end
end
