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

    def login(name)
      Handlers::CONNECTION.send(:user, :login, name)
    end

    private
    def on_update(sender, message)
      case message[:action]
      when :all
        on_all(message[:data])
      when :authenticate
        on_authenticate(message[:data])
      when :login
        on_login(message[:data])
      when :leave
        on_leave(message[:data])
      else
      end
    end

    def on_all(data)
      data.each { |id, user_data| @users[id] = User.from_data(user_data) }
      @users = users
      publish(self, :update, nil)
    end

    def on_authenticate(data)
      @current_user = User.from_data(data)
      publish(self, :update, nil)
    end

    def on_login(data)
      user = User.from_data(data)
      @users[user.id] = user
      update_user
      publish(self, :update, nil)
    end

    def on_leave(user_id)
      @users.delete(user_id)
      update_user
      publish(self, :update, nil)
      publish(self, :leave, user_id)
    end

    def update_user
      @users = @users.clone
    end
  end

  USERS_STORE = UsersStore.new
end
