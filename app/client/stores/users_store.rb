require 'handlers/notifier'
require 'handlers/connection'

module Stores
  class UsersStore
    include Handlers::Notifier

    def initialize
      Handlers::CONNECTION.subscribe(self, :user, :on_update)
    end

    def on_update(sender, message)
      case message[:action]
      when :all
        on_all_games(message[:data][:game_ids])
      when :new
        on_new_game(message[:data][:game_id])
      when :join
        on_join_game(message[:data])
      when :choose
        on_word_click(message[:data][:value], false)
      end
    end

    def login(id)
      Handlers::CONNECTION.send(:user, :login, { user_id: id })
    end
  end

  USERS_STORE = UsersStore.new
end
