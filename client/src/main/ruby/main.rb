Thread.abort_on_exception=true

require "colorize"

require "./src/main/ruby/screen"
Dir["./src/main/ruby/media/*.rb"].each {|file| require file}
Dir["./src/main/ruby/network/*.rb"].each {|file| require file}

class Main
	def initialize
		@config_count = 0
		@mediadirs = []
		@media = []
		@stop = false
		@prompting = false
		@screen = Screen.new
		@screen.main = self
		@client = Client.new
		@client.main = self
		@client.screen = @screen
	end

	def welcome
		@screen.print("Welcome to NetMedia Client")
	end

	def readConfig
		File.open("./src/main/resources/config.txt", "r") do |f|
			f.each_line do |line|
				lineArray = line.split("=")
				key = lineArray[0]
				case key
				when "mediadir"
					command = lineArray[1].chomp

					@mediadirs << command
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

	def readMedia
		@media = []
		@mediadirs.each{|path|
			Dir.foreach(path) do |item|
			next if item == '.' or item == '..'
				media << item
			end
		}
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
			when "reloadmedia"
				readMedia
			when "reconnect"
				client.open
				client.readLine
			else
				screen.print "Unknown command \"#{command}\"."
			end
		end
	end

	def stop
		@stop = true
		@prompting = false
		@screen.print("Stop command sent...")
		@client.closeConnections
	end

	attr_accessor :mediadirs, :media, :config_count, :prompting, :client, :screen
end

begin
	main = Main.new
	main.welcome
	main.readConfig
	main.readMedia
	
	main.screen.print("")
	client = main.client
	client.open
	client.readLine

	main.getCommands
rescue Interrupt => e
	main.stop
end