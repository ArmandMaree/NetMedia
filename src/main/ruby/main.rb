Dir["./src/main/ruby/video/*.rb"].each {|file| require file}

class Main
	@@config_count = 0
	@@videodirs = []

	def new

	end

	def welcome
		puts "Welcome to NetMedia"
	end

	def readConfig
		File.open("./src/main/resources/config.txt", "r") do |f|
			f.each_line do |line|
				lineArray = line.split("=")
				key = lineArray[0]
				case key
				when "videodir"
					command = lineArray[1]

					if line.end_with?("\n")
						command = command[0..(command.length - 2)]	
					end

					@@videodirs << command
					puts "Video directory: #{command}"
				end
				@@config_count += 1
			end
		end

		puts "Found #{@@config_count} configuration(s)."
	end

	def readVideos
		@@videodirs.each{|path|
			puts "Files found in #{path}:"
			Dir.foreach(path) do |item|
			next if item == '.' or item == '..'
				puts "\t #{item}"
			end
		}
	end

	attr_accessor :videodirs
	attr_accessor :config_count
end

main = Main.new
main.welcome
main.readConfig
puts ""
main.readVideos
