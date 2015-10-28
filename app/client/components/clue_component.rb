module Components
  class ClueComponent
    include React::Component

    params do
      requires :game
      requires :user
    end

    def render
      component_style = {
        display: 'inline-block',
        verticalAlign: 'top',
        width: '33%',
        fontSize: '3vw',
        textAlign: 'center',
        color: game.winner || game.current,
      }

      remaining_style = {
        fontSize: '2vw',
      }

      user = params[:user]

      div class: 'clue_component', style: component_style do
        div do
          "#{game.winner} team wins!"
        end if game.winner

        div do
          "#{game.current.upcase} TURN"
        end if !game.clue && !game.winner

        div do
          div { "Clue: #{game.clue} #{game.count}" }
          div style: remaining_style do
            "Remaining guesses: #{game.remaining}"
          end
        end if game.clue

        if game.started && game.active_member?(user.id)
          button { "Pass Turn" }.on(:click) { |e| Stores::GAMES_STORE.pass }
        end

        if !game.started && game.creator == user.id
          button { "Start Game" }.on(:click) { |e| Stores::GAMES_STORE.start }
        end
      end
    end
  end
end
