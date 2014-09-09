require "sinatra"
require "sinatra/streaming"
require "open3"
require "haml"
require "base64"

set server: 'thin', connections: []

get '/' do
  haml :index
end

get '/data' do
  # haml :data
end

get '/tail/:b64filepath', provides: 'text/event-stream' do
  stream :keep_open do |out|
    filepath = Base64.decode64(params[:b64filepath])

    settings.connections << out
    puts "New connection. #{settings.connections.count} connections open"

    out.callback do
      settings.connections.delete(out)
      puts "Connection closed. #{settings.connections.count} are open yet."
    end

    if File.exists?(filepath)
      cmd = 'tail -f "'+filepath+'"'

      puts cmd
      out.write "data: #{cmd}\n\n"

      Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
        loop do
          if stdout.eof?
            puts "stdout EOF"
            break
          end

          line = stdout.gets

          if out.closed?
            puts "This connection was closed"
            break
          end

          out.write "data: #{line.strip}\n\n"
          out.flush
        end
      end
    else
      out.write "data: File not found\n\n"
      out.flush
    end
  end
end
