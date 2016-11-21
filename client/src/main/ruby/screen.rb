class Screen
	def print(message)
		message.gsub! "\t", "        "
		puts "\r#{message}"
		STDOUT.flush
		@main.prompt
	end

	def prompt
		@main.prompt
	end

	attr_accessor :main
end