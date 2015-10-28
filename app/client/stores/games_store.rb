require 'handlers/notifier'
require 'handlers/connection'

module Stores
  class GamesStore
    include Handlers::Notifier

    attr_reader :game_list, :current_game

    def initialize
      @game_list = []
      Handlers::CONNECTION.subscribe(self, :game, :on_game_update)
    end

    def all
      Handlers::CONNECTION.send(:game, :all, nil)
    end

    def new_game(name)
      Handlers::CONNECTION.send(:game, :new, name)
    end

    def join(game_id)
      Handlers::CONNECTION.send(:game, :join, game_id)
    end

    def team(color, master)
      return unless user_join_team(Stores::USERS_STORE.current_user.id, color, master)
      data = { game_id: @current_game.id, color: color, master: master }
      Handlers::CONNECTION.send(:game, :team, data)
    end

    def start
      on_start
      Handlers::CONNECTION.send(:game, :start, @current_game.id)
    end

    def choose(value)
      return if !active_member? && !solo_master?
      return unless on_choose(value)
      data = { game_id: @current_game.id, value: value }
      Handlers::CONNECTION.send(:game, :choose, data)
    end

    def give(clue, count)
      return unless active_master?
      count = count.to_s
      return unless on_give(clue, count)
      data = { game_id: @current_game.id, clue: clue, count: count }
      Handlers::CONNECTION.send(:game, :give, data)
    end

    def pass
      return if !active_member? && !solo_master?
      return unless on_pass
      Handlers::CONNECTION.send(:game, :pass, @current_game.id)
    end

    def leave
      Handlers::CONNECTION.send(:game, :leave, @current_game.id)
      @current_game = nil
      publish(self, :update, nil)
    end

    private
    def on_game_update(sender, message)
      case message[:action]
      when :all
        on_all(message[:data])
      when :new
        on_new(message[:data])
      when :join
        on_join(message[:data])
      when :team
        user_id = message[:data][:user_id]
        color = message[:data][:color]
        master = message[:data][:master]
        on_team(user_id, color, master)
      when :start
        on_start
      when :choose
        on_choose(message[:data])
      when :give
        clue = message[:data][:clue]
        count = message[:data][:count]
        on_give(clue, count)
      when :pass
        on_pass
      when :leave
        on_leave(message[:data])
      end
    end

    def on_all(game_list)
      @game_list = game_list.map do |data|
        game = GameInfo.from_data(data)
      end
      publish(self, :update, nil)
    end

    def on_new(data)
      @game_list += [GameInfo.from_data(data)]
      publish(self, :update, nil)
    end

    def on_join(data)
      set_current_game(data)
    end

    def on_team(user_id, color, master)
      user_join_team(user_id, color, master)
    end

    def on_start
      @current_game.started = true
      set_current_game(@current_game.to_data)
    end

    def on_choose(value)
      return false unless @current_game.choose_word(value)
      set_current_game(@current_game.to_data)
      true
    end

    def on_give(clue, count)
      return false unless @current_game.give_clue(clue, count)
      set_current_game(@current_game.to_data)
      flash_screen
      true
    end

    def on_leave(user_id)
      if @current_game
        @current_game.leave(user_id)
        set_current_game(@current_game.to_data)
      end
    end

    def on_pass
      return false unless @current_game.pass
      set_current_game(@current_game.to_data)
      true
    end

    def user_join_team(user_id, color, master)
      return false unless @current_game.join_team(user_id, color, master)
      set_current_game(@current_game.to_data)
      true
    end

    def set_current_game(data)
      game = Game.from_data(data)
      @current_game = game
      publish(self, :update, nil)
    end

    def flash_screen
      %x{
        var el = document.getElementById('content');
        el.classList.add('flash');
        setTimeout(function() {
          el.classList.remove('flash');
        }, 1000);
      }
    end

    private
    def active_member?
      @current_game.active_member?(UsersStore::USERS_STORE.current_user.id)
    end

    def solo_master?
      @current_game.solo_master?(UsersStore::USERS_STORE.current_user.id)
    end

    def active_master?
      @current_game.active_master?(UsersStore::USERS_STORE.current_user.id)
    end
  end

  GAMES_STORE = GamesStore.new
end
