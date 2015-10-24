module Components
  class LobbyComponent
    include React::Component

    params do
      requires :games
    end

    def render
      div class_name: 'lobby' do
        params[:games].map do |game|
          button { game }.on(:click) { Stores::GAMES_STORE.join(game) }
        end

        button { "New Game" }.on(:click) do
          Stores::GAMES_STORE.new_game
        end
      end
    end
  end
end
