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
        on_all_games(message[:data])
      when :new
        on_new_game(message[:data])
      when :join
        on_join_game(message[:data])
      when :team
        on_join_team(message[:data])
      when :choose
        on_word_click(message[:data], false)
      end
    end

    def new_game
      Handlers::CONNECTION.send(:game, :new, nil)
    end

    def join_game(game_id)
      Handlers::CONNECTION.send(:game, :join, game_id)
    end

    def join_team(color, master)
      Handlers::CONNECTION.send(:game, :join_team, { color: color, master: master })
    end

    def on_word_click(value, send_to_server=true)
      return unless word = @current_game.choose_word(value)
      # This is a hack to get react rerendering to work.
      set_current_game(@current_game.to_data)

      if send_to_server
        data = { game_id: @current_game.id, value: value }
        Handlers::CONNECTION.send(:game, :choose, data)
      end
    end

    def on_all_games(game_ids)
      @games = game_ids
      publish(self, :update, nil)
    end

    def on_new_game(game_id)
      @games << game_id
      # This is a hack to get react rerendering to work.
      @games = @games.uniq
      publish(self, :update, nil)
    end

    def on_join_game(data)
      set_current_game(data)
    end

    private
    def set_current_game(data)
      game = Game.from_data(data)
      @current_game = game
      publish(self, :update, nil)
    end
  end

  GAMES_STORE = GamesStore.new
end
