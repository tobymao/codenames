module Components
  class LobbyComponent
    include React::Component

    params do
      requires :game_list
    end

    define_state(:name)
    define_state(:messages)
    define_state(:user_ids)

    before_mount do
      Stores::CHAT_STORE.subscribe(self, :update, :on_chat_update)
      Stores::CHAT_STORE.join(:main)
      Stores::CHAT_STORE.all(:main)
    end

    before_unmount do
      Stores::CHAT_STORE.leave(:main)
      Stores::CHAT_STORE.unsubscribe_all(self)
    end

    def render
      users = Stores::USERS_STORE.users

      component_style = {
        height: '90%',
        position: 'relative',
      }

      chat_container_style = {
        position: 'absolute',
        width: '100%',
        height: '40%',
        bottom: 0,
      }

      div style: component_style, class_name: 'lobby_component' do
        input(placeholder: 'Enter Game Name', value: self.name)
          .on(:change) {|e| self.name = e.target.value }
          .on(:key_down) { |e| new_game if (e.key_code == 13) }

        button { "New Game" }.on(:click) { new_game }

        params[:game_list].map do |info|
          div do
            div { "Name: #{info.name}" }
            div { "Creator: #{users[info.creator].try(:name)}" }
            render_team(info.team_a)
            render_team(info.team_b)
            button { 'Join' }.on(:click) { Stores::GAMES_STORE.join(info.id) }
          end
        end

        div(style: chat_container_style) do
          present ChatComponent, room_id: :main, messages: self.messages, user_ids: self.user_ids
        end
      end
    end

    def render_team(team)
      users = Stores::USERS_STORE.users
      master = users[team.master].name if team.master

      members = team.members.map do |user_id|
        users[user_id].try(:name)
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

    def new_game
      Stores::GAMES_STORE.new_game(self.name) if self.name
    end

    def on_chat_update(sender, message)
      self.messages = Stores::CHAT_STORE.messages[:main]
      self.user_ids = Stores::CHAT_STORE.users[:main]
    end
  end
end
