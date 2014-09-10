#!/usr/bin/env ruby

require 'socket'
require 'thread'

def log(text)
  File.open('data/socks.log', 'a') {|f| f.write text}
  puts text
end

localport = 9166
server = TCPServer.open(localport)
log "Listening on port tcp/#{localport}..."

MY_IP = "10.0.0.1"

@reply_650OK = "650 NOTICE New control connection opened.\r\n"
@reply_250OK = "250 OK\r\n"

@reply_bootstrap_phase = "250-status/bootstrap-phase=NOTICE BOOTSTRAP PROGRESS=100 TAG=done SUMMARY=\"Done\"\r\n"
@reply_net_listeners_socks = "250-net/listeners/socks=\"#{MY_IP}:9150\" \"127.0.0.1:9150\"\r\n"
@reply_Socks4Proxy = "250 Socks4Proxy\r\n"
@reply_Socks5Proxy = "250 Socks5Proxy\r\n"
@reply_HTTPSProxy = "250 HTTPSProxy\r\n"
@reply_ReachableAddresses = "250 ReachableAddresses\r\n"
@reply_UseBridges = "250 UseBridges=0\r\n"
@reply_Bridge = "250 Bridge\r\n"

def reply(client, string)
  log " -> #{string}"
  client.puts string
end

def process_getinfo(client, req)
  if req['status/bootstrap-phase']
    reply client, @reply_bootstrap_phase
    reply client, @reply_250OK
  elsif req['net/listeners/socks']
    reply client, @reply_net_listeners_socks
    reply client, @reply_250OK
  elsif req['Socks4Proxy']
    reply client, @reply_Socks4Proxy
  elsif req['Socks5Proxy']
    reply client, @reply_Socks5Proxy
  elsif req['HTTPSProxy']
    reply client, @reply_HTTPSProxy
  elsif req['ReachableAddresses']
    reply client, @reply_ReachableAddresses
  elsif req['UseBridges']
    reply client, @reply_UseBridges
  elsif req['Bridge']
    reply client, @reply_Bridge
  else 
    log "UNKNOWN GETINFO request!!!"
  end
end

def process_getconf(client, req)
  if req['Socks4Proxy']
    reply client, @reply_Socks4Proxy
  elsif req['Socks5Proxy']
    reply client, @reply_Socks5Proxy
  elsif req['HTTPSProxy']
    reply client, @reply_HTTPSProxy
  elsif req['ReachableAddresses']
    reply client, @reply_ReachableAddresses
  elsif req['UseBridges']
    reply client, @reply_UseBridges
  elsif req['Bridge']
    reply client, @reply_Bridge
  else 
    log "UNKNOWN GETCONF request!!!"
  end
end

def process_request(client)
  loop do
    begin
      req = client.gets  
      next unless req

      log "(#{Thread.current}) #{req}"
      
      if req.start_with? 'GETINFO'
        process_getinfo(client, req)
      elsif req.start_with? 'SETEVENTS'
        reply client, @reply_250OK
        log "SETEVENTS !!!"
        #reply client, @reply_650OK
        return
      elsif req.start_with? 'SIGNAL NEWNYM'
        reply client, @reply_250OK
        log "NEWNYM !!!"
        return
      elsif req.start_with? 'TAKEOWNERSHIP'
        reply client, @reply_250OK
      elsif req.start_with? 'AUTHENTICATE'
        reply client, @reply_250OK
      elsif req.start_with? 'RESETCONF'
        reply client, @reply_250OK
      elsif req.start_with? 'GETCONF'
        process_getconf(client, req)
      elsif req.start_with? 'SETCONF' or req.start_with? 'SAVECONF'
        reply client, @reply_250OK
      end
    rescue Exception => e
      log e.message
    end
  end
end

loop do
  Thread.start(server.accept) do |client|
    
    port, ip = Socket.unpack_sockaddr_in(client.getpeername)
    log "(#{Thread.current}) New connection from: #{ip}:#{port}"
    
    process_request(client)

  end
end
