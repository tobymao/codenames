require 'handlers/notifier'
require 'handlers/connection'

module Stores
  class GamesStore
    include Handlers::Notifier

    attr_reader :games, :current_game

    def initialize
      @games = []
      Handlers::CONNECTION.subscribe(self, :game, :on_game_update)
    end

    def on_game_update(sender, message)
      case message[:action]
      when :all
        on_all(message[:data])
      when :new
        on_new(message[:data])
      when :join
        on_join(message[:data])
      when :team
        user_id = message[:data][:user_id]
        color = message[:data][:color]
        master = message[:data][:master]
        on_team(user_id, color, master)
      when :choose
        on_choose(message[:data], false)
      when :give
        clue = message[:data][:clue]
        count = message[:data][:count]
        on_give(clue, count, false)
      end
    end

    def new_game
      Handlers::CONNECTION.send(:game, :new, nil)
    end

    def join_game(game_id)
      Handlers::CONNECTION.send(:game, :join, game_id)
    end

    def join_team(color, master)
      user_join_team(Stores::USERS_STORE.current_user.id, color, master)
      data = { game_id: @current_game.id, color: color, master: master }
      Handlers::CONNECTION.send(:game, :team, data)
    end

    def on_all(game_ids)
      @games = game_ids
      publish(self, :update, nil)
    end

    def on_new(game_id)
      @games << game_id
      # This is a hack to get react rerendering to work.
      @games = @games.uniq
      publish(self, :update, nil)
    end

    def on_join(data)
      set_current_game(data)
    end

    def on_team(user_id, color, master)
      user_join_team(user_id, color, master)
    end

    def on_choose(value, send_to_server=true)
      return unless @current_game.choose_word(value)
      # This is a hack to get react rerendering to work.
      set_current_game(@current_game.to_data)

      if send_to_server
        data = { game_id: @current_game.id, value: value }
        Handlers::CONNECTION.send(:game, :choose, data)
      end
    end

    def on_give(clue, count, send_to_server=true)
      count = count.to_s
      return unless @current_game.give_clue(clue, count)
      set_current_game(@current_game.to_data)

      if send_to_server
        data = { game_id: @current_game.id, clue: clue, count: count }
        Handlers::CONNECTION.send(:game, :give, data)
      end
    end

    private
    def set_current_game(data)
      game = Game.from_data(data)
      @current_game = game
      publish(self, :update, nil)
    end

    def user_join_team(user_id, color, master)
      @current_game.join_team(user_id, color, master)
      set_current_game(@current_game.to_data)
      publish(self, :update, nil)
    end
  end

  GAMES_STORE = GamesStore.new
end
