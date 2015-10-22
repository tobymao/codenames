require 'stores/users_store'

module Components
  class LoginComponent
    include React::Component

    KEY_ENTER = 13

    define_state(:name)

    def render
      div class_name: 'login' do
        div { "Enter Name" }

        input(class_name: "edit", value: self.name)
          .on(:change) {|e| self.name = e.target.value }
          .on(:key_down) { |e| submit if (e.key_code == KEY_ENTER) }
      end
    end

    def submit
      Stores::USERS_STORE.login(self.name)
    end
  end
end
