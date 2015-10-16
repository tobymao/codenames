require 'stores/game_store'

module Components
  class GameComponent
    include React::Component

    define_state(:game) { Stores::GameStore.instance }

    before_mount do
    end


    def render
      div class_name: "game" do
        h1 { "Game view" }
      end
    end

    def on_game_msg(data)
    end
  end
end

