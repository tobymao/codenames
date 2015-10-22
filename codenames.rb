require 'require_all'
require 'celluloid/current'
require 'fortitude'
require 'reel'

require 'opal'
require 'opal/util'
require 'opal-browser'
require 'reactive-ruby'

require_all 'app/server'
require_all 'app/client/shared'

LIB_INCLUDE = "app/client/include.rb"
LIB_PATH = "build/lib.js"
APP_PATH = "build/app.js"
SOURCE_MAP_PATH = "build/app.js.map"

def build_lib(uglify)
  time = Time.now
  lib = Opal::Builder.build("include").to_s
  lib = Opal::Util.uglify(lib) if uglify
  File.write(LIB_PATH, lib)
  puts "Lib assets built in #{Time.now - time}"
end

def build_app(uglify)
  time = Time.now
  builder = Opal::Builder.new
  app = builder.build("app").to_s
  app = Opal::Util.uglify(app) if uglify

  #source_map = builder.source_map
  #app << '//# sourceMappingURL=app.js.map'
  #File.write(SOURCE_MAP_PATH, source_map)

  File.write(APP_PATH, app)

  puts "App assets built in #{Time.now - time}"
end

Opal.append_path "app/client"

build_lib(true) if !File.exists?(LIB_PATH) || File.mtime(LIB_PATH) < File.mtime(LIB_INCLUDE)
build_app(false)

container = Celluloid::Supervision::Configuration.deploy([
  { type: Servers::WebServer, as: :web_server },
  { type: Servers::UserServer, as: :user_server },
  { type: Servers::SocketServer, as: :socket_server },
  { type: Servers::GameServer, as: :game_server },
])

sleep
