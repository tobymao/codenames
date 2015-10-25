module Components
  class MainComponent
    include React::Component

    define_state(:current_user)
    define_state(:users) { [] }

    define_state(:current_game)
    define_state(:games) { [] }

    before_mount do
      Stores::USERS_STORE.subscribe(self, :update, :on_user_update)
      Stores::GAMES_STORE.subscribe(self, :update, :on_game_update)
    end

    before_unmount do
      Stores::USERS_STORE.unsubscribe_all(self)
      Stores::GAMES_STORE.unsubscribe_all(self)
    end

    def render
      div class_name: 'main' do
        if self.current_user
          if current_game
            present GameComponent, user: self.current_user, users: self.users, game: self.current_game
          else
            present LobbyComponent, games: self.games
          end
        else
          present LoginComponent
        end
      end
    end

    def on_user_update(sender, message)
      self.current_user = Stores::USERS_STORE.current_user
      self.users = Stores::USERS_STORE.users
    end

    def on_game_update(sender, message)
      self.current_game = Stores::GAMES_STORE.current_game
      self.games = Stores::GAMES_STORE.games
    end
  end
end
