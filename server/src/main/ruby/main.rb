Thread.abort_on_exception=true

require "colorize"
require "socket"

require "./src/main/ruby/screen"
Dir["./src/main/ruby/video/*.rb"].each {|file| require file}
Dir["./src/main/ruby/network/*.rb"].each {|file| require file}

class Main
	def initialize
		@clients = []
		@config_count = 0
		@stop = false
		@prompting = false
		@screen = Screen.new
		@screen.main = self
		@server = Server.new
		@server.main = self
		@server.screen = @screen
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

					@videodir = command
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
				@server.listMedia
			else
				screen.print "Unknown command \"#{command}\"."
			end
		end
	end

	def stop
		@stop = true
		@prompting = false
		@screen.print("Stop command sent...")
		@server.closeConnections
	end

	attr_accessor :videodirs, :config_count, :prompting, :server, :screen
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

	main.getCommands
rescue Interrupt => e
	main.stop
end