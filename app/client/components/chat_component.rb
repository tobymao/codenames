module Components
  class ChatComponent
    include React::Component

    params do
      requires :messages
      requires :room_id
      requires :user_ids
    end

    define_state(:text)

    after_update do
      %x{
        var node = #{@native}.refs.messages.getDOMNode();
        node.scrollTop = node.scrollHeight;
      }
    end

    def render
      messages = params[:messages] || []
      user_ids = params[:user_ids] || []
      users = Stores::USERS_STORE.users

      component_style = {
        position: 'relative',
        height: '100%',
      }

      messages_style = {
        float: 'left',
        overflowY: 'auto',
        height: '80%',
        width: '80%',
      }

      users_style = {
        float: 'right',
        overflowY: 'auto',
        height: '80%',
        width: '20%',
      }

      name_style = {
        display: 'inline-block',
        marginRight: '0.5vw',
      }

      message_style = {
        display: 'inline-block',
      }

      input_style = {
        width: '100%',
        bottom: 0,
      }

      div style: component_style, class_name: 'chat_component' do
        div(style: messages_style, ref: :messages) do
          messages.map do |message|
            user = users[message.user_id]

            div do
              div(style: name_style) { "#{user.name}:" }
              div(style: message_style) { message.text}
            end
          end if messages
        end

        div(style: users_style) do
          user_ids.map do |user_id|
            user = users[user_id]
            div { "#{user.name}" }
          end
        end

        input(style: input_style, value: self.text)
          .on(:change) {|e| self.text = e.target.value }
          .on(:key_down) { |e| submit if (e.key_code == 13) }
      end
    end

    def submit
      Stores::CHAT_STORE.say(params[:room_id], self.text)
      self.text = nil
    end
  end
end
