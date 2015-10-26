module Components
  class ChatComponent
    include React::Component

    params do
      requires :messages
      requires :game_id
      requires :users
    end

    define_state(:text)

    after_update do
      %x{
        var node = #{@native}.refs.messages.getDOMNode();
        node.scrollTop = node.scrollHeight;
      }
    end

    def render
      messages = params[:messages]

      component_style = {
        width: '100%',
        height: '15%',
        position: 'relative',
      }

      container_style = {
        overflowY: 'auto',
        height: '70%',
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
        position: 'absolute',
        bottom: 0,
      }

      div style: component_style, class_name: 'chat_component' do
        div(style: container_style, ref: :messages) do
          messages.map do |message|
            user = params[:users][message.user_id]

            div do
              div(style: name_style) { "#{user.name}:" }
              div(style: message_style) { message.text}
            end
          end if messages
        end

        input(style: input_style, value: self.text)
          .on(:change) {|e| self.text = e.target.value }
          .on(:key_down) { |e| submit if (e.key_code == 13) }
      end
    end

    def submit
      Stores::CHAT_STORE.say(params[:game_id], self.text)
      self.text = nil
    end
  end
end
