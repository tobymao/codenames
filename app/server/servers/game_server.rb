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
        all(user_id)
      when 'new'
        new_game(user_id, message['data'])
      when 'join'
        join(user_id, message['data'])
      when 'team'
        game_id = message['data']['game_id']
        color = message['data']['color']
        master = message['data']['master']
        team(user_id, game_id, color, master)
      when 'start'
        start(user_id, message['data'])
      when 'choose'
        game_id = message['data']['game_id']
        value = message['data']['value']
        choose(user_id, game_id, value)
      when 'give'
        game_id = message['data']['game_id']
        clue = message['data']['clue']
        count = message['data']['count']
        give(user_id, game_id, clue, count)
      when 'pass'
        pass(user_id, message['data'])
      when 'leave'
        leave(user_id, message['data'])
      else
        error "GameServer received unknown action #{message['action']}"
      end
    end

    def all(user_id)
      send(user_id, :all, game_list)
    end

    def new_game(user_id, name)
      game = Game.new(
        id: SecureRandom.uuid,
        first: Random.rand(2) == 0 ? :red : :blue,
        creator: user_id,
        name: name,
      )
      game.watchers << user_id
      @games[game.id] = game
      send_join_game(user_id, game)
      send_all(:new, game.to_info.to_data)
    end

    def join(user_id, game_id)
      return unless game = @games[game_id]
      game.watchers << user_id
      send_join_game(user_id, game)
    end

    def team(user_id, game_id, color, master)
      return unless game = @games[game_id]
      return if game.started
      game.join_team(user_id, color.to_sym, master)
      data = { user_id: user_id, color: color, master: master}
      send_game_watchers(game, :team, data, user_id)
      send_all(:all, game_list)
    end

    def start(user_id, game_id)
      return unless game = @games[game_id]
      return unless game.creator == user_id
      return if game.started
      game.started = true
      send_game_watchers(game, :start, nil, user_id)
      send_all(:all, game_list)
    end

    def choose(user_id, game_id, value)
      return unless game = @games[game_id]
      return unless game.started
      return if !game.active_member?(user_id) && !game.solo_master?(user_id)
      word = game.choose_word(value)
      send_game_watchers(game, :choose, value, user_id)
    end

    def give(user_id, game_id, clue, count)
      return unless game = @games[game_id]
      return unless game.active_master?(user_id)
      game.give_clue(clue, count)
      data = { clue: clue, count: count }
      send_game_watchers(game, :give, data, user_id)
    end

    def pass(user_id, game_id)
      return unless game = @games[game_id]
      return unless game.started
      return if !game.active_member?(user_id) && !game.solo_master?(user_id)
      game.pass
      send_game_watchers(game, :pass, nil, user_id)
    end

    def leave(user_id, game_id)
      return unless game = @games[game_id]

      game.leave(user_id)

      if game.empty?
        @games.delete(game_id)
      else
        send_game_watchers(game, :leave, user_id, user_id)
      end

      send_all(:all, game_list)
    end

    def send_game_watchers(game, kind, data, ignore_user_id=nil)
      game.watchers.each do |user_id|
        next if user_id == ignore_user_id
        send(user_id, kind, data)
      end
    end

    def send_join_game(user_id, game)
      send(user_id, :join, game.to_data)
    end

    def game_list
      @games.values.delete_if(&:started).map do |game|
        game.to_info.to_data
      end
    end

    # Notifications
    def on_socket_close(pattern, user_id)
      @games.values.each { |game| leave(user_id, game.id) }
    end
  end
end
