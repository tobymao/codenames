module Components
  class GameComponent
    include React::Component

    params do
      requires :user
      requires :users
      requires :game
    end

    define_state(:clue)
    define_state(:count)

    def render
      return unless game = params[:game]

      styles = {
        clue: {
          display: 'inline-block',
          margin: '0',
          width: '25%',
          fontSize: '2vw',
          textAlign: 'center',
        },
      }

      div class_name: 'game' do
        render_team(game.team_a)
        render_team(game.team_b, true)

        div style: { textAlign: 'center' }, class_name: 'clue_giver' do
          div style: styles[:clue] do
            div { 'Clue' }
            input(value: self.clue)
              .on(:change) {|e| self.clue = e.target.value }
          end

          div style: styles[:clue] do
            div { 'Count' }
            input(value: self.count, list: 'counts')
              .on(:change) {|e| self.count = e.target.value }
          end

          datalist id: 'counts' do
            (0..9).map { |i| option value: i }
            option value: 'Infinity'
          end

          button(value: self.clue) { "Give Clue" }
            .on(:click) { |e| puts "submittin" }
        end

        present GridComponent, grid: game.grid, master: game.master?(user.id)
      end
    end

    def render_team(team, right=nil)
      master = params[:users][team.master].name if team.master

      members = team.members.map do |user_id|
        params[:users][user_id].name
      end

      style = {
        display: 'inline-block',
        color: team.color == :red ? 'red' : 'blue',
        fontSize: '2vw',
        width: '50%',
      }

      style[:textAlign] = 'right' if right

      div style: style do
        div { "Team: #{team.color}" }
        div { "Spy Master: #{master}" }
        button { "Be #{team.color} spy master" }.on(:click) do
          Stores::GAMES_STORE.join_team(team.color, true)
        end
        div { "Members: #{members}" }
        button { "Join #{team.color}" }.on(:click) do
          Stores::GAMES_STORE.join_team(team.color, false)
        end
      end
    end
  end
end
