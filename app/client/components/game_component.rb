
module Components
  class GameComponent
    include React::Component

    params do
      requires :users
      requires :game
    end

    def render
      return unless game = params[:game]

      div class_name: "game" do
        render_team(game.team_a)
        render_team(game.team_b)
        present GridComponent, grid: game.grid
      end
    end

    def render_team(team)
      master = params[:users][team.master].name if team.master

      members = team.members.map do |user_id|
        params[:users][user_id].name
      end

      div do
        div { "Team: #{team.color}" }
        div { "Spy Master: #{master}" }
        div { "Members: #{members}" }
      end
    end
  end
end
