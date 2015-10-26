module Components
  class GameComponent
    include React::Component

    params do
      requires :user
      requires :users
      requires :game
    end

    define_state(:messages)

    before_mount do
      Stores::CHAT_STORE.subscribe(self, :update, :on_chat_update)

      if game = params[:game]
        Stores::CHAT_STORE.join(game.id)
      end
    end

    before_unmount do
      Stores::CHAT_STORE.leave(params[:game].id)
      Stores::CHAT_STORE.unsubscribe_all(self)
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
        present ChatComponent, game_id: game.id, messages: self.messages, users: users
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

    def on_chat_update(sender, message)
      self.messages = Stores::CHAT_STORE.rooms[params[:game].id]
    end
  end
end
