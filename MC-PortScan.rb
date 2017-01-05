#!/usr/bin/env ruby

begin
    require 'timeout'
rescue
    puts "Required libary not found!"
    puts "Please run 'gem install timeout' to fix this problem"
    exit 130
end
    
require_relative 'lib/McQuery/query'

trap "SIGINT" do
  puts ""
  puts ""
  puts "Exiting"
  
  Kernel.exit(false)
end

hostname = ""
min_port = 1000
max_port = 65535
max_threads = 2000
delay = 0.05

case ARGV.length
when 0
	puts "USAGE: #{File.basename(__FILE__)} [HOSTNAME] [MIN PORT] [MAX PORT] [MAX THREADS] [DELAY]"
	exit 130
when 1
	hostname = ARGV[0]
when 2
	hostname = ARGV[0]
	min_port = ARGV[1]
when 3
	hostname = ARGV[0]
	min_port = ARGV[1]
	max_port = ARGV[2]
when 4
	hostname = ARGV[0]
	min_port = ARGV[1]
	max_port = ARGV[2]
	max_threads = ARGV[3]
when 5
	hostname = ARGV[0]
	min_port = ARGV[1]
	max_port = ARGV[2]
	max_threads = ARGV[3]
	delay = ARGV[4]
end

min_port = min_port.to_s.to_i
max_port = max_port.to_s.to_i
max_threads = max_threads.to_s.to_i
delay = delay.to_s.to_f

$threads = 0

begin
    File.delete("log.txt")
rescue
end

if min_port < 0 || max_port > 65535 || min_port > max_port
    puts "Wrong Port Range! Max: 65535, Min: 0"
    exit 130
end

begin
    require 'socket'
    hostname = IPSocket::getaddress("#{hostname}")
rescue
    puts "Couldn't resolve '#{hostname}'!"
    exit 130
end

times = max_port-min_port
port = min_port
servers = 0
puts ""
puts "[-] Scanning Range #{min_port}-#{max_port} on #{hostname}!"
puts ""

open('log.txt', 'a') { |f|
    f.puts "[-] Scanning Range #{min_port}-#{max_port} on #{hostname}!"
}

print "[-] Checking Port #{port}..."
Thread.abort_on_exception = true

times.times do
    print "\r"
    $threads = Thread.list.length
	
    me = Thread.new {
		really_me = me
        begin
            Timeout.timeout(5) do
                lport = port
                query = McQuery::Ping.new(hostname, port)
                if query.players_online != ""
                    if query.protocol_version != ""
                        if "#{query.players_online}/#{query.players_max}" != "/"
                            #Todo: Check online / offline mode of the server, I need to port this code to ruby: https://gist.github.com/barneygale/5823d12b8ea72d550cd6
                            print "\r"
                            puts "[!] Found Server on #{hostname}:#{lport}! (Protocol=#{query.protocol_version}, Software=#{query.server_version} Players=#{query.players_online}/#{query.players_max})"
                            open('log.txt', 'a') { |f|
                                f.puts "- Found Server on #{hostname}:#{lport}! (Protocol=#{query.protocol_version}, Software=#{query.server_version} Players=#{query.players_online}/#{query.players_max})"
                            }
                            servers = servers+1
                        end
                    end
                end
            end
		Thread.kill(really_me)
		puts "Killed"
		
        rescue
        end
        
    }
    port = port+1
	unless max_threads == 0
		while $threads > max_threads 
			$threads = Thread.list.length
			sleep 0.01
		end
	end
    print "[-] Checking Port #{port}... (Threads: #{$threads}, Delay: #{delay.round(5)})"
    sleep(delay)
end

puts ""
puts ""
puts "[-] Done! Scanned Range: #{min_port}-#{max_port} and found #{servers} Server(s)"

open('log.txt', 'a') { |f|
    f.puts "Done! Scanned Range: #{min_port}-#{max_port} and found #{servers} Server(s)"
}

exit 130