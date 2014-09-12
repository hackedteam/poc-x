require 'eventmachine'
require 'eventmachine-tail'
require 'sinatra'
require 'sinatra/streaming'
require 'thin'
require 'haml'
require 'json'
require 'logger'

require_relative 'tailer'
require_relative 'service'

set server: 'thin', connections: []

configure do
  set :threaded, false
  Tailer.truncate_all
  $logger = Logger.new(__dir__+"/data/poc-x.log")
end

get '/' do
  @services = Service.list
  haml :index
end

get '/service/:name/:action' do
  stream :keep_open do |out|
    action = params[:action]

    raise "Forbidden" unless %w[start stop status].include?(action)

    out.callback { out.close }

    $logger.info "Request #{action} for service #{params[:name]}"

    Service.exec(params[:name], action) do |output, status|
      unless out.closed?
        out << {output: output, status: status}.to_json
        out.close
      end
    end
  end
end

get '/stream', provides: 'text/event-stream' do
  stream :keep_open do |out|
    timer = EventMachine::PeriodicTimer.new(20) { out << "keep" }
    tailers = []

    out.callback do
      timer.cancel
      tailers.map(&:close)
    end

    JSON.parse(params[:files]).each do |hash|
      hash.symbolize_keys!

      tailers << Tailer.new(hash[:name], hash) do |line, filename|
        json = {line: line, filename: filename}.to_json
        out << "event: tail\ndata: #{json}\n\n" unless out.closed?
      end
    end
  end
end
