require 'stores/users_store'

module Components
  class LoginComponent
    include React::Component

    define_state(:name)

    def render
      login_input_style =  {
        WebkitAppearance: 'none',
        MozAppearance: 'none',
        display: 'block',
        margin: '0',
        width: '50%',
        height: '40px',
        lineHeight: '40px',
        fontSize: '17px',
        border: '1px solid #bbb',
      }

      div class_name: 'login_component' do
        div { "Enter Name" }

        input(style: login_input_style, value: self.name)
          .on(:change) {|e| self.name = e.target.value }
          .on(:key_down) { |e| submit if (e.key_code == 13) }

        button { "Login" }.on(:click) { submit }
      end
    end

    def submit
      Stores::USERS_STORE.login(self.name)
    end
  end
end
