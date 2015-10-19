require 'handlers/notifier'

module Stores
  class GameStore
    include Handlers::Notifier

    attr_accessor :game

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
      Handlers::CONNECTION.send(:game, :move, word)
      # do internal update for real time shits
    end

    private
    def set_game(new_game)
      @game = new_game
      publish(self, :update, nil)
    end
  end

  GAME_STORE = GameStore.new
end
