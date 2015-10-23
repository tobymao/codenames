module Views
  class Index < Base
    def content
      html do
        head do
          meta name: 'viewport', content: 'width=device-width', 'initial-scale' => 1, 'maximum-scale' => 1
          title "Codenames"
          script src: "build/lib.js"
          script src: "build/app.js"
        end
      end

      body do
        div id: 'content'
      end
    end
    static :content
  end
end
