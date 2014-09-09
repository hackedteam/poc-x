class App < Sinatra::Base
  set server: 'thin', connections: []

  configure do
    set :threaded, false
  end

  get '/' do
    haml :index
  end

  get '/tail/:b64filepath', provides: 'text/event-stream' do
    stream :keep_open do |out|
      filepath = File.expand_path Base64.decode64(params[:b64filepath])

      settings.connections << out
      puts "New connection. #{settings.connections.count} connections open"

      out.callback do
        settings.connections.delete(out)
        puts "Connection closed. #{settings.connections.count} are open yet."
      end

      EventMachine::file_tail(filepath, nil, -1) do |filetail, line|
        out << "data: #{line.strip}\n\n"
      end
    end
  end
end
