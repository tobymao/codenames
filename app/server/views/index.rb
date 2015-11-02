module Views
  class Index < Base
    def content
      html do
        head do
          title "Codenames"
          meta name: 'viewport', content: 'width=device-width', 'initial-scale' => 1, 'maximum-scale' => 1, 'user-scalable' => 0
          link rel: 'stylesheet', type: 'text/css', href: '/main.css'
          script src: '/lib.js'
          script src: '/app.js'
        end
      end

      body do
        div id: 'content'
      end
    end
    static :content
  end
end
