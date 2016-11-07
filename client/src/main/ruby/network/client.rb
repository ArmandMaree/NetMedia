require "socket"
Dir["../*.rb"].each {|file| require file}

class Client
	def initialize
		@hostname = 'localhost'
		@port = 5000
		@socket = nil
		@name = Socket.gethostname
		@main = nil		
		@screen = nil
		@requests = []
		@stopped = false
	end

	def open
		@screen.print("Connecting to #{@hostname}:#{@port}")
		@socket = TCPSocket.open(@hostname, @port)
		@stopped = false
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
									write(mediaItem)
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
			
			@stopped = true
		end
	end

	def write(message)
		@socket.puts(message)
	end

	def closeConnections
		@requests << "command:close"
		while !@stopped
			sleep(0.5)
		end
	end

	attr_accessor :hostname, :port, :name, :main, :screen
end
