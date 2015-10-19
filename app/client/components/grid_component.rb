module Components
  class GridComponent
    include React::Component
    include Handlers::Notifier

    params do
      requires :game
      requires :delegate
    end

    def render
      game = params[:game]
      return if game.empty?

      div class_name: "grid" do
        div { game[:id] }
        game[:words].map do |word|
          div { word[:value] }.on(:click) { delegate.on_word_click(word) }
        end
      end
    end
  end
end
