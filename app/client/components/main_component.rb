module Components
  class MainComponent
    include React::Component

    define_state(:current_user)
    define_state(:users) { [] }

    define_state(:current_game)
    define_state(:games_info) { [] }

    before_mount do
      Stores::USERS_STORE.subscribe(self, :update, :on_user_update)
      Stores::GAMES_STORE.subscribe(self, :update, :on_game_update)
    end

    before_unmount do
      Stores::USERS_STORE.unsubscribe_all(self)
      Stores::GAMES_STORE.unsubscribe_all(self)
    end

    def render
      main_style = {
        margin: '1vw 1vw 0 1vw',
      }

      div do
        present NavComponent, game: self.current_game if self.current_user

        div style: main_style, class: 'main' do
          if self.current_user
            if current_game
              present GameComponent, user: self.current_user, users: self.users, game: self.current_game
            else
              present LobbyComponent, users: self.users, games_info: self.games_info
            end
          else
            present LoginComponent
          end
        end
      end
    end

    def on_user_update(sender, message)
      self.current_user = Stores::USERS_STORE.current_user
      self.users = Stores::USERS_STORE.users
    end

    def on_game_update(sender, message)
      self.current_game = Stores::GAMES_STORE.current_game
      self.games_info = Stores::GAMES_STORE.games_info
    end
  end
end
