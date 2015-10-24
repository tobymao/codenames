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
        clue_input: {
          display: 'inline-block',
          margin: '0',
          width: '25%',
          fontSize: '2vw',
          textAlign: 'center',
        },
        clue: {
          display: 'inline-block',
          width: '33%',
          fontSize: '3vw',
          textAlign: 'center',
          color: game.current,
        },
      }
      div class_name: 'game' do
        render_team(game.team_a)

        div style: styles[:clue] do
          div do
            "#{game.current} team's turn"
          end

          div style: { color: game.current } do
            "#{game.clue} #{game.count} - Remaining #{game.remaining}" if game.clue
          end
        end

        render_team(game.team_b, true)

        div style: { textAlign: 'center' }, class_name: 'clue_giver' do
          div style: styles[:clue_input] do
            div { 'Clue' }
            input(value: self.clue)
              .on(:change) {|e| self.clue = e.target.value }
          end

          div style: styles[:clue_input] do
            div { 'Count' }
            input(value: self.count, list: 'counts')
              .on(:change) {|e| self.count = e.target.value }
          end

          datalist id: 'counts' do
            (0..9).map { |i| option value: i }
            option value: 'Infinity'
          end

          button(value: self.clue) { "Give Clue" }.on(:click) do |e|
            Stores::GAMES_STORE.on_give(self.clue, self.count)
          end
        end

        present GridComponent, grid: game.grid, master: game.master?(user.id)
      end
    end

    def render_team(team, right=false)
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
