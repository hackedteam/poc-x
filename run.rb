require 'eventmachine'
require 'eventmachine-tail'
require "sinatra"
require "sinatra/streaming"
require 'sinatra/base'
require 'thin'
require "haml"
require "base64"

require_relative 'app.rb'
# fix shutdown bug
require_relative 'thin_backend.rb'

EM.run do
  server  = 'thin'
  host    = '127.0.0.1'
  port    = '8181'
  web_app = App.new

  dispatch = Rack::Builder.app do
    map '/' do
      run web_app
    end
  end

  # NOTE that we have to use an EM-compatible web-server. There
  # might be more, but these are some that are currently available.
  unless ['thin', 'hatetepe', 'goliath'].include? server
    raise "Need an EM webserver, but #{server} isn't"
  end

  # Start the web server. Note that you are free to run other tasks
  # within your EM instance.
  Rack::Server.start({
    app:    dispatch,
    server: server,
    Host:   host,
    Port:   port
  })
end
