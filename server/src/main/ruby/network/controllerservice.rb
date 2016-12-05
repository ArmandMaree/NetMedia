require "socket"
require "thread"

Dir["../*.rb"].each {|file| require file}

class ControllerService
	attr_accessor :port, :main, :screen, :controller, :server, :player

	def initialize
		@port = 5001
		@server = nil
		@controller = nil
		@server = nil
		@controllerServer = nil
		@player = nil
	end

	def open
		@controllerServer = TCPServer.open(@port)
	end

	def waitForController
		Thread.new do
			@screen.print("Waiting for controller...")
			loop {
				begin
					@controller = @controllerServer.accept
					@screen.print("Controller connected.")

					class << @controller
						attr_accessor :communicate
					end
					@controller.communicate = Mutex.new

					loop {
						if @controller.closed?
							throw :stop
						end
						while line = @controller.gets.chomp
							if line == "listmedia"
								media = @server.listMedia

								media.each do |clientMedia|
									clientMedia.each_index do |mediaIndex|
										sendToController("#{clientMedia[mediaIndex][0] + "@" + clientMedia[mediaIndex][2]}")
									end
								end
								sendToController("DONE")
							elsif line == "listdevices"
								@server.clients.each do |client|
									sendToController("#{client.name}")
								end
								sendToController("DONE")
							elsif line == "listlocal"
								Dir.foreach("/home/netmedia/uploads/") do |item|
									next if item == '.' or item == '..'
									sendToController("server@" + "#{item}")
								end
								sendToController("DONE")
							elsif line == "getMedia"
								clientName = @controller.gets.chomp
								filename = @controller.gets.chomp
								@server.getMedia(clientName, filename) do |message|
									sendToController(message)
								end
								sendToController("DONE")
							elsif line == "playmedia"
								filename = "/home/netmedia/uploads/" + @controller.gets.chomp
								@player.playFullscreen(filename)
							elsif line == "stopmedia"
								puts "CALLED STOP"
								@player.stop
							else
								sendToController("UNKNOWN COMMAND")
							end
						end
					}
				rescue NoMethodError
					@screen.print("Controller disconnected.                    ")
				end
			}
		end
	end

	def closeController()
		@screen.print("Closing controller...")
		sendToController("command:close")
		reply = @controller.gets.chomp
		if reply != "OK"
			@screen.print("Controller does not want to close: #{reply}...")
		end

		@controller.close
	end

	def sendToController(message)
		@controller.puts message
	end
end
