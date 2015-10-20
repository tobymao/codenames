require 'stores/games_store'

module Components
  class GameComponent
    include React::Component
    include Handlers::Notifier

    define_state(:game) { }

    before_mount do
      Stores::GAMES_STORE.subscribe(self, :update, :on_update)
    end

    def render
      return unless self.game

      div class_name: "game" do
        present GridComponent, grid: self.game.grid, delegate: Stores::GAMES_STORE
      end
    end

    def on_update(sender, message)
      self.game = Stores::GAMES_STORE.current_game
    end
  end
end
