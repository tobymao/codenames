module Components
  class ChatComponent
    include React::Component

    params do
      requires :messages
      requires :game_id
      requires :users
    end

    define_state(:text)

    def render
      messages = params[:messages]

      div class_name: 'chat_component' do
        messages.map do |message|
          # fix this
          user = params[:users][message.user_id]
          div { "#{user ? user.name : "toby"}: #{message.text}" }
        end if messages

        input(value: self.text)
          .on(:change) {|e| self.text = e.target.value }
          .on(:key_down) { |e| submit if (e.key_code == 13) }
      end
    end

    def submit
      Stores::CHAT_STORE.say(params[:game_id], self.text)
    end
  end
end
