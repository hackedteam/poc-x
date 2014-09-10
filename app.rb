require_relative 'file_stream'

class App < Sinatra::Base
  set server: 'thin', connections: []

  configure do
    set :threaded, false
    FileStream.delete_all
  end

  get '/' do
    haml :index
  end

  get '/stream/:filename', provides: 'text/event-stream' do
    stream :keep_open do |out|
      FileStream.new(params[:filename], unique: (params[:unique] == 'true')).stream(out)
    end
  end
end
