require 'handlers/notifier'
require 'shared/game'

module Stores
  class GameStore
    include Handlers::Notifier

    attr_accessor :game_data, :game

    def initialize
      Handlers::NOTIFIER.subscribe(self, :game, :on_game_update)
    end

    def on_game_update(sender, message)
      case message[:action]
      when :new
        set_game(message[:data])
      when :join
      end
    end

    def on_word_click(word)
      return unless chosen_word = @game.choose_word(word.value)
      # This is a hack to get react rerendering to work.
      @game = Game.from_data(@game.to_data)
      publish(self, :update, nil)
      Handlers::CONNECTION.send(:game, :move, chosen_word.to_data)
    end

    private
    def set_game(game)
      @game = Game.from_data(game)
      publish(self, :update, nil)
    end
  end

  GAME_STORE = GameStore.new
end
