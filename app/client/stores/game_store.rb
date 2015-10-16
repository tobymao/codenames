require 'handlers/notifier'

module Stores
  class GameStore
    def initialize
      puts "Does this initialize??"
      Handlers::DefaultNotifier.subscribe(self, :game, :on_game_update)
    end

    def test
    end

    def on_game_update(sender, kind, data)
      puts "Got Game update #{data}"
    end
  end
end
