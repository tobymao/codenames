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
      when 'team'
        game_id = message['data']['game_id']
        color = message['data']['color']
        master = message['data']['master']
        join_team(user_id, game_id, color, master)
      when 'choose'
        game_id = message['data']['game_id']
        value = message['data']['value']
        choose_word(user_id, game_id, value)
      else
      end
    end

    def all_games(user_id)
      send(user_id, :all, @games.keys)
    end

    def new_game(user_id)
      game = Game.new(id: SecureRandom.uuid, first: Random.rand(2) == 0 ? :red : :blue)
      @games[game.id] = game
      send_join_game(user_id, game)
      send_all(:new, game.id)
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

    def join_team(user_id, game_id, color, master)
      game = @games[game_id]
      team = game.team_for_color(color)

      if master
        team.master = user_id
      else
        team.members << user_id
      end
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


    def send_join_game(user_id, game)
      send(user_id, :join, game.to_data)
    end

    # To Do: Clean up user...
    def on_socket_close(pattern, user_id)
      info "socket closed #{user_id}"
    end
  end
end
