module Components
  class NavComponent
    include React::Component

    params do
      requires :game
    end

    def render
      component_style = {
         backgroundColor: 'gray',
         margin: '0',
      }

      link_style = {
        display: 'inline-block',
        cursor: 'pointer',
        marginRight: '1%',
      }

      div style: component_style, class: 'nav_component' do
        if params[:game]
          div(style: link_style) { '< Leave Game' }
            .on(:click) { Stores::GAMES_STORE.leave }
        end
        div(style: link_style) { 'About' }
      end
    end
  end
end
