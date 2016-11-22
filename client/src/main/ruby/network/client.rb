require "socket"
require "zlib"
require "colorize"
require "rubygems"
# require "net/ssh"
require "net/scp"

Dir["../*.rb"].each {|file| require file}

class Client
	attr_accessor :hostname, :port, :name, :main, :screen, :username, :password

	def initialize
		@hostname = 'localhost'
		@port = 5000
		@socket = nil
		@name = Socket.gethostname
		@main = nil		
		@screen = nil
		@requests = []
		@stopped = false
		@username = nil
		@password = nil
		@terminate = false
	end

	def open
		connected = false
		@stopped = true
		numDots = 0

		while !connected && !@terminate
			begin
				@socket = TCPSocket.open(@hostname, @port)
				connected = true
			rescue
				dots = ""

				for i in 0..(numDots - 1)
					dots << "."
				end

				for i in numDots..3
					dots << " "
				end

				numDots = (numDots + 1) % 4
				print("\rConnection to server failed. Retrying#{dots}".red)
				sleep(0.5)
			else
				@screen.print("Connected to #{@hostname}:#{@port}                            ".green)
			end
		end
	end

	def readLine
		Thread.new do
			@screen.print("Waiting for server to send a command...")
			catch :stop do
				loop {
					while line = @socket.gets.chomp
						if line.start_with?("request:")
							case line[8..(line.length - 1)]
							when "name"
								write(@name)
							when "num-media"
								write(@main.media.length)
							when "list-media"
								@main.media.each { |mediaItem|
									write(mediaItem.fullname)
								}
							when "version"
								write("1")
							when "requests"
								if @requests.length == 0
									write("DONE")
								else
									write(@requests[0])
									@requests.delete_at(0)
								end
							when /checkmedia:.+/
								found = false

								@main.media.each { |item|
									if item.fullname == line[19..(line.length - 1)]
										write("EXISTS")
										found = true
										break
									end
								}

								if !found
									write("MISSING")
								end
							when /getmedia:.+/
								@main.media.each { |item|
									if item.fullname == line[17..(line.length - 1)]
										print "\rLogging in via SSH...".green
										startTime = Time.now.to_i
										numUpdates = 0
										
										Net::SCP.start(@hostname, @username, :password => @password) do |scp|
											scp.upload! item.fullname, "/home/netmedia/uploads/" do |ch, name, sent, total|
												print "\rTransferring data. #{(sent * 100.0 / total).round(2)}\% complete.".green
												if (Time.now.to_i - startTime) >= numUpdates
													numUpdates += 1
													write("Transferring data. #{(sent * 100.0 / total).round(2)}\% complete.")		
												end
											end
										end

										@screen.print("Transfer complete. #{Time.now.to_i - startTime} seconds elapsed.".green)
										write("Transfer complete. #{Time.now.to_i - startTime} seconds elapsed.")
										break
									end
								}
							else
								@screen.print("Unknown request \"#{line[8..(line.length - 1)]}\".")
							end
						elsif line.start_with?("command:")
							case line[8..(line.length - 1)]
							when "reload-media"
								@main.readMedia
							when "close"
								write("OK")
								@screen.print("Socket closing...")
								@stopped = true
								throw :stop
							else
								@screen.print("Unknown command \"#{line[8..(line.length - 1)]}\".")
							end
						else
							@screen.print(line)
						end
					end
				}
			end
			
			if !@terminate
				sleep(1)
				open
			end
		end
	end

	def read_file(filename, size)
		File.open(filename) do |file|
			while (buffer = file.read(size)) do
				yield buffer
			end
		end
	end

	def compress(input)
		Zlib::Deflate.deflate(input)
	end

	def write(message)
		@socket.puts(message)
	end

	def closeConnections
		preStopped = @stopped
		@terminate = true
		@requests << "command:close"
		while !@stopped
			sleep(0.2)
		end

		if !preStopped
			sleep(1)
		end
	end
end
