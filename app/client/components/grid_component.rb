module Components
  class GridComponent
    include React::Component

    params do
      requires :grid
      requires :master
    end

    define_state(:hover)

    def word_style(word)
      color =
        case word.color
        when :red
          'red'
        when :blue
          'blue'
        when :neutral
          'burlywood'
        when :assasin
          'black'
        end

      covered = word.chosen? && self.hover != word.value

      {
        color: covered ? color : 'black',
        margin: '0.5%',
        border: "0.3vw solid #{params[:master] ? color : 'black'}",
        width: '15%',
        padding: '2.5%' '0%' '2.5%' '0%',
        textAlign: 'center',
        background: covered ? color : 'white',
        fontSize: '2vw',
        cursor: 'pointer',
      }
    end

    def render
      return unless grid = params[:grid]

      component_style = {
        width: '100%',
      }

      table style: component_style, class_name: "grid_component" do
        grid.map do |row|
          tr {
            row.map do |word|
              td(style: word_style(word)) { word.value }
                .on(:click) { on_click(word) }
                .on(:mouse_enter) { self.hover = word.value }
                .on(:mouse_leave) { self.hover = nil }
            end
          }
        end
      end
    end

    def on_click(word)
       Stores::GAMES_STORE.choose(word.value)
       self.hover = nil
    end
  end
end
