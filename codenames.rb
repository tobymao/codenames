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

LIB_INCLUDE = 'app/client/include.rb'
CSS_SOURCE = 'assets/stylesheets/main.css'


LIB_BUILD_PATH = 'build/public/lib.js'
APP_BUILD_PATH = 'build/public/app.js'
CSS_BUILD_PATH = 'build/public/main.css'
SOURCE_MAP_PATH = 'build/public/app.js.map'

def build_lib(uglify)
  time = Time.now
  lib = Opal::Builder.build('include').to_s
  lib = Opal::Util.uglify(lib) if uglify
  File.write(LIB_BUILD_PATH, lib)
  puts "Lib assets built in #{Time.now - time}"
end

def build_app(uglify)
  time = Time.now
  builder = Opal::Builder.new
  app = builder.build('app').to_s
  app = Opal::Util.uglify(app) if uglify

  #source_map = builder.source_map
  #app << '//# sourceMappingURL=app.js.map'
  #File.write(SOURCE_MAP_PATH, source_map)

  File.write(APP_BUILD_PATH, app)

  puts "App assets built in #{Time.now - time}"
end

def build_css
  FileUtils.cp_r(CSS_SOURCE, CSS_BUILD_PATH)
end

Opal.append_path "app/client"

build_lib(true) if !File.exists?(LIB_BUILD_PATH) || File.mtime(LIB_BUILD_PATH) < File.mtime(LIB_INCLUDE)
build_app(false)
build_css

container = Celluloid::Supervision::Configuration.deploy([
  { type: Servers::WebServer, as: :web_server },
  { type: Servers::UserServer, as: :user_server },
  { type: Servers::SocketServer, as: :socket_server },
  { type: Servers::GameServer, as: :game_server },
  { type: Servers::ChatServer, as: :chat_server },
])

sleep
