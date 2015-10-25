module Components
  class ClueComponent
    include React::Component

    params do
      requires :game
    end

    def render
      component_style = {
        display: 'inline-block',
        verticalAlign: 'top',
        width: '33%',
        fontSize: '3vw',
        textAlign: 'center',
        color: game.current,
      }

      clue_style = {
        color: game.current,
      }

      remaining_style = {
        fontSize: '2vw',
      }

      div class: 'clue_component', style: component_style do
        div class: 'turn' do
          "#{game.current.upcase} TURN"
        end if !game.clue

        div class: 'clue', style: clue_style do
          div { "Clue: #{game.clue} #{game.count}" }
          div style: remaining_style do
            "Remaining guesses: #{game.remaining}"
          end
        end if game.clue

        button { "Pass Turn" }.on(:click) { |e| Stores::GAMES_STORE.pass }
      end
    end
  end
end
