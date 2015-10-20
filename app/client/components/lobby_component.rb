require 'stores/games_store'

module Components
  class LobbyComponent
    include React::Component

    define_state(:games) { [] }

    before_mount do
      Stores::GAMES_STORE.subscribe(self, :update, :on_update)
    end

    def render
      div class_name: 'lobby' do
        self.games.map do |game|
          button { game }.on(:click) { Stores::GAMES_STORE.join_game(game) }
        end

        button { "New Game" }.on(:click) do
          Stores::GAMES_STORE.new_game
        end
      end
    end

    def on_update(sender, message)
      self.games = Stores::GAMES_STORE.games
    end
  end
end
