module Handlers
  module Title
    def set_title(message)
      `document.title = #{message};`
      after(2) { reset_title }
    end

    def reset_title
      `document.title = 'Codenames'`
    end
  end
end
