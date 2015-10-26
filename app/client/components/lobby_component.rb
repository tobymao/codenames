module Components
  class LobbyComponent
    include React::Component

    params do
      requires :games_info
      requires :users
    end

    def render
      div class_name: 'lobby' do
        button { "New Game" }.on(:click) do
          Stores::GAMES_STORE.new_game
        end

        params[:games_info].map do |info|
          div do
            render_team(info.team_a)
            render_team(info.team_b)
            button { 'Join' }.on(:click) { Stores::GAMES_STORE.join(info.id) }
          end
        end
      end
    end

    def render_team(team)
      master = params[:users][team.master].name if team.master

      members = team.members.map do |user_id|
        params[:users][user_id].name
      end

      style = {
        display: 'inline-block',
        marginRight: '1vw',
      }

      div style: style do
        div { "Team: #{team.color}" }
        div { "Master: #{master}" } if master
        div { "Members: #{members}" } if members
      end
    end
  end
end
