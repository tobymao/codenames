require 'stores/game_store'

module Components
  class GameComponent
    include React::Component
    include Handlers::Notifier

    define_state(:game) { }

    before_mount do
      Stores::GAME_STORE.subscribe(self, :update, :on_update)
    end

    def render
      return unless self.game

      div class_name: "game" do
        h1 { "Game view" }
        present GridComponent, grid: self.game.grid, delegate: Stores::GAME_STORE
      end
    end

    def on_update(sender, message)
      self.game = Stores::GAME_STORE.game
    end
  end
end
