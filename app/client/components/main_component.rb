require 'handlers/connection'

module Components
  class MainComponent
    include React::Component

    def render
      div class_name: "main" do
        h1 { "Code Names" }
        present GameComponent
      end
    end
  end
end
