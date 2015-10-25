module Components
  class GameComponent
    include React::Component

    params do
      requires :user
      requires :users
      requires :game
    end

    def render
      return unless game = params[:game]

      master = game.master?(user.id)

      div class_name: 'game_component' do
        render_team(game.team_a)
        present ClueComponent, game: game
        render_team(game.team_b)
        present GiveComponent if master
        present GridComponent, grid: game.grid, master: master
      end
    end

    def render_team(team)
      master = params[:users][team.master].name if team.master

      members = team.members.map do |user_id|
        params[:users][user_id].name
      end

      style = {
        display: 'inline-block',
        color: team.color,
        fontSize: '2vw',
        width: '33%',
      }

      style[:textAlign] = 'right' if team == game.team_b

      div style: style do
        div { "Team: #{team.color}" }
        div { "Spy Master: #{master}" }
        button { "Be #{team.color} spy master" }.on(:click) do
          Stores::GAMES_STORE.team(team.color, true)
        end
        div { "Members: #{members}" }
        button { "Join #{team.color}" }.on(:click) do
          Stores::GAMES_STORE.team(team.color, false)
        end
      end
    end
  end
end
