module Routers
  class HTTPRouter
    def self.route(connection, request)
      path = request.url

      if path == "/"
        connection.respond :ok, Views::Index.new.to_html
      elsif path.starts_with?("/build/")
        File.open(path.sub(/^\/+/, '')) { |file| connection.respond :ok, file }
      else
        connection.respond :not_found, "Not Found"
      end
    end
  end
end
