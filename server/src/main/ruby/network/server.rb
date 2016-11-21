require "socket"
require "thread"
require "colorize"
require "zlib"

Dir["../*.rb"].each {|file| require file}

class Server
	attr_accessor :port, :main, :screen, :stop

	def initialize
		@port = 5000
		@server = nil
		@clients = []
		@screen = nil
		@stop = false
	end

	def open
		@server = TCPServer.open(@port)
	end

	def sendToClient(client, message)
		client.puts message
	end

	def waitForClients
		puts "Starting listening thread..."
		Thread.new do
			@screen.print("Waiting for client...")
			catch :stop do
				loop {
					Thread.start(@server.accept) do |client|
						if @stop
							sendToClient(client, "command:close")
							reply = client.gets.chomp
							if reply == "OK"
								@screen.print("Closing #{client.name}...")
							else
								@screen.print("#{client.name} does not want to close: #{reply}...")
							end

							client.close
							throw :stop
						end

						@clients << client
						sendToClient(client, "request:name")
						name = client.gets.chomp
						class << client
							attr_accessor :name
						end
						client.name = name
						class << client
							attr_accessor :clientVersion
						end
						sendToClient(client, "request:version")
						version = client.gets.chomp
						client.clientVersion = version

						class << client
							attr_accessor :communicate
						end
						client.communicate = Mutex.new

						Thread.new do
							listenForClient(client)
						end
						sendToClient(client, "Connected to server successfully.")
						@screen.print("Client " + client.name + " connected.")
					end
				}
			end
		end
	end

	def listenForClient(client)
		catch :stop do
			loop {
				sleep(5)
				while !client.communicate.try_lock
					
				end

				catch :done do
					loop {
						if client.closed?
							throw :stop
						end
						sendToClient(client, "request:requests")

						while line = client.gets.chomp
							if line == "DONE"
								throw :done
							elsif line.start_with?("command")
								case line[8..(line.length - 1)]
								when "close"
									closeClient(client)
									throw :stop
								end
							else
								@screen.print(client.name + ": " + line)
							end
						end
					}
				end


				client.communicate.unlock
			}
		end
	end

	def listMediaForClient(client)
		while !client.communicate.try_lock
			
		end
		sendToClient(client, "command:reload-media")
		sendToClient(client, "request:num-media")
		numMedia = client.gets.chomp.to_i
		sendToClient(client, "request:list-media")
		media = []
		@screen.print("Media at client \"#{client.name}\": ")

		for i in 0..(numMedia - 1) do
			media << client.gets.chomp
			@screen.print("\t#{media.last}")
		end

		client.communicate.unlock
	end

	def listMedia
		@clients.each {|client|
			listMediaForClient(client)
		}
	end

	def getMedia(clientName, filename)
		client = nil

		@clients.each {|c|
			if c.name == clientName
				client = c
				break
			end
		}

		if client == nil
			@screen.print("No client with the name \"#{clientName}\".".red)
		else
			while !client.communicate.try_lock
			
			end
			sendToClient(client, "request:checkmedia:#{filename}")
			response = client.gets.chomp

			if response != "EXISTS"
				@screen.print("Client says media item does not exist.".red)
			else
				sendToClient(client, "request:getmedia:#{filename}")
				puts("Starting transfer now.")
				bytesReceived = 0
				file = File.open(@main.mediadir + filename.rpartition('/').last, "wb")

				while status = client.gets.chomp
					print "\r#{status}".green
					STDOUT.flush
					if  status =~ /Transfer complete(.*)/
						screen.print("\r#{status}".green)
						break
					end
					if status == nil || status == ""
						sleep(1)
					end
				end
			end

			client.communicate.unlock
		end
	end

	def decompress(input)
		Zlib::Inflate.inflate(input)
	end

	def closeClient(client)
		@screen.print("Closing #{client.name}...")
		sendToClient(client, "command:close")
		reply = client.gets.chomp
		if reply != "OK"
			@screen.print("#{client.name} does not want to close: #{reply}...")
		end

		client.close
		for i in 0..(@clients.length - 1) do
			if @clients[i].name == client.name
				@clients.delete_at(i)
			end
		end
	end

	def closeConnections
		@stop = true
		@clients.each {|client| 
			closeClient(client)
		}
		@screen.print("Closing server...")
	end
end
