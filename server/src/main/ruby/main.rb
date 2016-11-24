Thread.abort_on_exception=true

require "colorize"
require "socket"

require "./src/main/ruby/screen"
Dir["./src/main/ruby/video/*.rb"].each {|file| require file}
Dir["./src/main/ruby/network/*.rb"].each {|file| require file}

class Main
	attr_accessor :mediadir, :config_count, :prompting, :server, :screen, :controller

	def initialize
		@config_count = 0
		@stop = false
		@prompting = false

		@screen = Screen.new
		@screen.main = self

		@server = Server.new
		@server.main = self
		@server.screen = @screen

		@player = Player.new

		@controller = ControllerService.new
		@controller.main = self
		@controller.screen = @screen
		@controller.server = @server
	end

	def welcome
		@screen.print("Welcome to NetMedia Server")
	end

	def readConfig
		File.open("./src/main/resources/config.txt", "r") do |f|
			f.each_line do |line|
				lineArray = line.split("=")
				key = lineArray[0]
				case key
				when "mediadir"
					command = lineArray[1]

					if line.end_with?("\n")
						command = command[0..(command.length - 2)]	
					end

					if !command.end_with?('/')
						command = command + '/'
					end

					@mediadir = command
					@screen.print("Media directory: #{command}")
				else
					@screen.print("Unknown option \"#{key}\"")
					@config_count -= 1
				end
				@config_count += 1
			end
		end

		@screen.print("Found #{@config_count} configuration(s).")
	end

	def prompt
		if @prompting
			print "\rnetmedia> ".light_blue
			STDOUT.flush
		end
	end

	def getCommands
		while !@stop
			@prompting = true
			prompt
			command = gets.chomp.downcase

			case command
			when "stop"
				stop
			when "listmedia"
				media = @server.listMedia

				media.each do |clientMedia|
					@screen.print("Media for client #{clientMedia[0][0]}")
					clientMedia.each_index do |mediaIndex|
						@screen.print("\t#{clientMedia[mediaIndex][2]}")
					end
				end
			when "listclients"
				@screen.print("Clients connected to server:")
				@server.clients.each do |client|
					@screen.print("\t#{client.name}")
				end
			when "getmedia"
				print "Name of client: "
				# clientName = gets.chomp
				clientName = "armandmaree-desktop"
				print "File name of media: "
				# filename = gets.chomp
				filename = "/home/armandmaree/Videos/NetMedia/SampleVideo_1280x720_5mb.mp4"
				# filename = "/home/armandmaree/Videos/NetMedia/The.Avengers.2012.720p.BluRay.x264.YIFY.mp4"
				@server.getMedia(clientName, filename) do |message|
					print (message.green)
				end
				@screen.print("")
			when "playmedia"
				print "File name of media: "
				# filename = "/home/netmedia/uploads/" + gets.chomp
				filename = "/home/netmedia/uploads/SampleVideo_1280x720_5mb.mp4"
				# filename = "/home/netmedia/uploads/The.Avengers.2012.720p.BluRay.x264.YIFY.mp4"
				@player.playFullscreen(filename)
			when "listlocal"
				puts "Local media:"
				Dir.foreach("/home/netmedia/uploads/") do |item|
					next if item == '.' or item == '..'
					puts "\t#{item}"
				end
			when "stopmedia"
				@player.stop
			else
				@screen.print "Unknown command \"#{command}\"."
			end
		end
	end

	def stop
		@stop = true
		@prompting = false
		@screen.print("Stop command sent...")
		@server.closeConnections
	end
end

begin
	main = Main.new
	main.welcome
	main.readConfig
	main.screen.print("")

	server = main.server
	server.open
	server.waitForClients
	main.screen.print("")

	controller = main.controller
	controller.open
	controller.waitForController	

	main.getCommands
	@player.stop
rescue Interrupt => e
	main.stop
end