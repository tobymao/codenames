module Components
  class GridComponent
    include React::Component

    params do
      requires :grid
      requires :master
    end

    def word_style(word)
      color =
        case word.owner
        when :red
          'red'
        when :blue
          'blue'
        when :neutral
          'burlywood'
        when :assasin
          'darkslategray'
        end

      {
        display: 'inline-block',
        color: word.chosen? ? color : 'black',
        margin: '0.5%',
        border: "0.5vw solid #{params[:master] ? color : 'black'}",
        width: '17%',
        padding: '3%' '0%' '3%' '0%',
        textAlign: 'center',
        background: word.chosen? ? color : 'white',
        fontSize: '2.5vw',
        cursor: 'pointer',
      }
    end

    def render
      return unless grid = params[:grid]

      div class_name: "grid" do
        grid.map do |row|
          div {
            row.map do |word|
              div(style: word_style(word)) { word.value }
                .on(:click) { Stores::GAMES_STORE.on_word_click(word.value) }
            end
          }
        end
      end
    end
  end
end
