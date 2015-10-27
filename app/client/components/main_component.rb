module Components
  class MainComponent
    include React::Component

    define_state(:current_user)
    define_state(:current_game)
    define_state(:game_list) { [] }

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
              present GameComponent, user: self.current_user, game: self.current_game
            else
              present LobbyComponent, game_list: self.game_list
            end
          else
            present LoginComponent
          end
        end
      end
    end

    def on_user_update(sender, message)
      self.current_user = Stores::USERS_STORE.current_user
    end

    def on_game_update(sender, message)
      self.current_game = Stores::GAMES_STORE.current_game
      self.game_list = Stores::GAMES_STORE.game_list
    end
  end
end
