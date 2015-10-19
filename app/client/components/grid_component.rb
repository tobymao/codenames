module Components
  class GridComponent
    include React::Component
    include Handlers::Notifier

    params do
      requires :grid
      requires :delegate
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
          'dimgray'
        end if word.chosen?

      {
        display: 'inline-block',
        color: color || 'black',
        margin: '5px',
      }
    end

    def render
      return unless grid = params[:grid]
     
      div class_name: "grid" do
        grid.map do |row|
          div {
            row.map do |word|
              div(style: word_style(word)) { word.value }
                .on(:click) { delegate.on_word_click(word) }
            end
          }
        end
      end
    end
  end
end
