require 'stores/users_store'

module Components
  class LoginComponent
    include React::Component

    KEY_ENTER = 13

    define_state(:name)

    def render
      styles = {
        login_box: {
            WebkitAppearance: 'none',
            MozAppearance: 'none',
            display: 'block',
            margin: '0',
            width: '50%',
            height: '40px',
            lineHeight: '40px',
            fontSize: '17px',
            border: '1px solid #bbb',
        },
      }

      div class_name: 'login' do
        div { "Enter Name" }

        input(style: styles[:login_box], value: self.name)
          .on(:change) {|e| self.name = e.target.value }
          .on(:key_down) { |e| submit if (e.key_code == KEY_ENTER) }
      end
    end

    def submit
      Stores::USERS_STORE.login(self.name)
    end
  end
end
