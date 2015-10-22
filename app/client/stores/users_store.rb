require 'handlers/notifier'
require 'handlers/connection'

module Stores
  class UsersStore
    include Handlers::Notifier

    attr_reader :users, :current_user

    def initialize
      @users = {}
      Handlers::CONNECTION.subscribe(self, :user, :on_update)
    end

    def on_update(sender, message)
      case message[:action]
      when :all
        on_all_users(message[:data])
      when :authenticate
        on_authenticated(message[:data])
      when :login
        on_login(message[:data])
      else
      end
    end

    def login(name)
      Handlers::CONNECTION.send(:user, :login, name)
    end

    def on_authenticated(data)
      @current_user = User.from_data(data)
      publish(self, :update, nil)
    end

    def on_login(data)
      user = User.from_data(data)
      @users[user.id] = user
      publish(self, :update, nil)
    end

    def on_all_users(data)
      data.each { |id, user_data| @users[id] = User.from_data(user_data) }
      @users = users
      publish(self, :update, nil)
    end
  end

  USERS_STORE = UsersStore.new
end
