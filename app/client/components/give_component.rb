module Components
  class GiveComponent
    include React::Component

    define_state(:clue)
    define_state(:count)

    def render
      component_style = {
        textAlign: 'center',
      }

      input_container_style = {
        display: 'inline-block',
        width: '30%',
        marginRight: '0.5vw',
        fontSize: '2vw',
        textAlign: 'center',
      }

      input_style = {
        width: '100%',
      }

      div style: component_style, class_name: 'give_component' do
        div style: input_container_style do
          div { 'Clue' }
          input(style: input_style, value: self.clue)
            .on(:change) {|e| self.clue = e.target.value }
        end

        div style: input_container_style do
          div { 'Count' }
          input(style: input_style, value: self.count, list: 'counts')
            .on(:change) {|e| self.count = e.target.value }
        end

        datalist id: 'counts' do
          (0..9).map { |i| option value: i }
          option value: 'Infinity'
        end

        button(value: self.clue) { "Give Clue" }.on(:click) do |e|
          Stores::GAMES_STORE.give(self.clue, self.count)
        end
      end
    end
  end
end
