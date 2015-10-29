module Components
  class GameComponent
    include React::Component

    params do
      requires :user
      requires :game
    end

    define_state(:messages)
    define_state(:user_ids)

    before_mount do
      Stores::CHAT_STORE.subscribe(self, :update, :on_chat_update)

      if game = params[:game]
        Stores::CHAT_STORE.join(game.id)
        Stores::CHAT_STORE.all(game.id)
      end
    end

    before_unmount do
      Stores::CHAT_STORE.leave(params[:game].id)
      Stores::CHAT_STORE.unsubscribe_all(self)
    end

    def render
      return unless game = params[:game]

      is_master = game.master?(user.id)

      component_style = {
        height: '95%',
        position: 'relative',
      }

      chat_container_style = {
        width: '100%',
        height: '20%',
        bottom: 0,
      }

      div style: component_style, class_name: 'game_component' do
        render_team(game.team_a)
        present ClueComponent, game: game, user: user
        render_team(game.team_b)
        present GridComponent, grid: game.grid, is_master: is_master
        div style: chat_container_style do
          present ChatComponent, room_id: game.id, messages: self.messages, user_ids: self.user_ids
        end
      end
    end

    def render_team(team)
      users = Stores::USERS_STORE.users
      master = users[team.master].try(:name) if team.master
      game = params[:game]

      members = team.members.map do |user_id|
        users[user_id].try(:name)
      end.compact

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
        end if !master && !game.started
        div { "Members: #{members}" }
        button { "Join #{team.color}" }.on(:click) do
          Stores::GAMES_STORE.team(team.color, false)
        end unless game.started
      end
    end

    def on_chat_update(sender, message)
      game_id = params[:game].id
      self.messages = Stores::CHAT_STORE.messages[game_id]
      self.user_ids = Stores::CHAT_STORE.users[game_id]
    end
  end
end
