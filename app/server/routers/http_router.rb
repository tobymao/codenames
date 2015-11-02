module Routers
  class HTTPRouter
    def self.route(connection, request)
      path = request.url

      if path == "/"
        connection.respond :ok, Views::Index.new.to_html
      else
        begin
          File.open("build/public" << path) { |file| connection.respond :ok, file }
        rescue
          connection.respond :not_found
        end
      end
    end
  end
end
