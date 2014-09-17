#!/usr/bin/env ruby

require 'socket'
require 'thread'

def log(text)
  File.open('data/socks.log', 'a') {|f| f.write text.chomp + "\n"}
  puts text
end

localport = 9166
server = TCPServer.open(localport)
log "Listening on port tcp/#{localport}..."

MY_IP = "10.0.0.1"

@reply_650_NOTICE = "650 NOTICE New control connection opened.\r\n"
@reply_250OK = "250 OK\r\n"

@reply_bootstrap_phase = "250-status/bootstrap-phase=NOTICE BOOTSTRAP PROGRESS=100 TAG=done SUMMARY=\"Done\"\r\n"
@reply_net_listeners_socks = "250-net/listeners/socks=\"#{MY_IP}:9150\"\r\n"
@reply_Socks4Proxy = "250 Socks4Proxy\r\n"
@reply_Socks5Proxy = "250 Socks5Proxy\r\n"
@reply_HTTPSProxy = "250 HTTPSProxy\r\n"
@reply_ReachableAddresses = "250 ReachableAddresses\r\n"
@reply_UseBridges = "250 UseBridges=0\r\n"
@reply_Bridge = "250 Bridge\r\n"


class Event
  def initialize
    @lock = Mutex.new
    @cond = ConditionVariable.new
  end

  def set
    log "----- signal set -----"
    @lock.synchronize do
      @cond.broadcast
   end
  end

  def wait
    log "----- signal wait -----"
    @lock.synchronize do
      @cond.wait(@lock)
    end
  end
end

@event = Event.new

def reply(client, string)
  log " -> #{string}"
  client.puts string
end

def process_getinfo(client, req)
  if req['status/bootstrap-phase']
    reply client, @reply_bootstrap_phase
    reply client, @reply_250OK
    @vent.set
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

def bootstrap_events(client)
  log "SENDING BOOTSTRAP EVENTS..."

  reply client, "650 NOTICE Bootstrapped 5%: Connecting to directory server.\r\n"
  sleep 0.1
  reply client, "650 STATUS_CLIENT NOTICE BOOTSTRAP PROGRESS=5 TAG=conn_dir SUMMARY=\"Connecting to directory server\"\r\n"
  sleep 0.1
  reply client, "650 NOTICE Bootstrapped 10%: Finishing handshake with directory server.\r\n"
  sleep 0.1
  reply client, "650 STATUS_CLIENT NOTICE BOOTSTRAP PROGRESS=10 TAG=handshake_dir SUMMARY=\"Finishing handshake with directory server\"\r\n"
  sleep 0.1
  reply client, "650 NOTICE Bootstrapped 15%: Establishing an encrypted directory connection.\r\n"
  sleep 0.1
  reply client, "650 STATUS_CLIENT NOTICE BOOTSTRAP PROGRESS=15 TAG=onehop_create SUMMARY=\"Establishing an encrypted directory connection\"\r\n"
  sleep 0.1
  reply client, "650 NOTICE Bootstrapped 20%: Asking for networkstatus consensus.\r\n"
  sleep 0.1
  reply client, "650 STATUS_CLIENT NOTICE BOOTSTRAP PROGRESS=20 TAG=requesting_status SUMMARY=\"Asking for networkstatus consensus\"\r\n"
  sleep 0.1
  reply client, "650 NOTICE Bootstrapped 25%: Loading networkstatus consensus.\r\n"
  sleep 0.1
  reply client, "650 STATUS_CLIENT NOTICE BOOTSTRAP PROGRESS=25 TAG=loading_status SUMMARY=\"Loading networkstatus consensus\"\r\n"
  sleep 0.1
  reply client, "650 STATUS_CLIENT NOTICE CONSENSUS_ARRIVED\r\n"
  sleep 0.1
  reply client, "650 NOTICE Bootstrapped 45%: Asking for relay descriptors.\r\n"
  sleep 0.1
  reply client, "650 STATUS_CLIENT NOTICE BOOTSTRAP PROGRESS=45 TAG=requesting_descriptors SUMMARY=\"Asking for relay descriptors\"\r\n"
  sleep 0.1
  reply client, "650 NOTICE We now have enough directory information to build circuits.\r\n"
  sleep 0.1
  reply client, "650 STATUS_CLIENT NOTICE ENOUGH_DIR_INFO\r\n"
  sleep 0.1
  reply client, "650 NOTICE Bootstrapped 80%: Connecting to the Tor network.\r\n"
  sleep 0.1
  reply client, "650 STATUS_CLIENT NOTICE BOOTSTRAP PROGRESS=80 TAG=conn_or SUMMARY=\"Connecting to the Tor network\"\r\n"
  sleep 0.1
  reply client, "650 NOTICE Bootstrapped 90%: Establishing a Tor circuit.\r\n"
  sleep 0.1
  reply client, "650 STATUS_CLIENT NOTICE BOOTSTRAP PROGRESS=90 TAG=circuit_create SUMMARY=\"Establishing a Tor circuit\"\r\n"
  sleep 0.1
  reply client, "650 NOTICE Tor has successfully opened a circuit. Looks like client functionality is working.\r\n"
  sleep 0.1
  reply client, "650 NOTICE Bootstrapped 100%: Done.\r\n"
  sleep 0.1
  reply client, "650 STATUS_CLIENT NOTICE BOOTSTRAP PROGRESS=100 TAG=done SUMMARY=\"Done\"\r\n"
  sleep 0.1
  reply client, "650 STATUS_CLIENT NOTICE CIRCUIT_ESTABLISHED\r\n"
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
        @event.wait
        bootstrap_events(client)
        while(true)
          @event.wait
          log "EVENT NOTICE..."
          reply client, @reply_650_NOTICE
        end
      elsif req.start_with? 'SIGNAL NEWNYM'
        reply client, @reply_250OK
        log "NEWNYM !!!"
        @event.set
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
