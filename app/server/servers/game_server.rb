module Servers
  class GameServer < BaseServer
    def initialize
      @name = :game
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
        join_game(user_id, message['data'])
      when 'choose'
        choose_word(user_id, message['data']['game_id'], message['data']['value'])
      else
      end
    end

    def all_games(user_id)
      send(user_id, :all, @games.keys)
    end

    def new_game(user_id)
      game = Game.new(id: SecureRandom.uuid, first: Random.rand(2) == 0 ? :red : :blue)
      game.team_a.members << user_id
      @games[game.id] = game

      send_join_game(user_id, game)
      send_all(:new, game.id)
    end

    def choose_word(user_id, game_id, value)
      game = @games[game_id]
      word = game.choose_word(value)

      user_ids = game.team_a.members + game.team_b.members

      user_ids.each do |id|
        next if user_id == id
        send(user, :choose, value)
      end
    end

    def join_game(user_id, game_id)
      game = @games[game_id]

      if game.team_a.members.size > game.team_b.members.size
        game.team_b.members << user_id
      else
        game.team_a.members << user_id
      end

      send_join_game(user_id, game)
    end

    def send_join_game(user_id, game)
      send(user_id, :join, game.to_data)
    end

    # To Do: Clean up user...
    def on_socket_close(pattern, user_id)
      info "socket closed #{user_id}"
    end
  end
end
