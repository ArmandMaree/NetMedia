class MediaItem
	attr_accessor :name
	attr_reader :path

	def initialize
		@path = nil
		@name = nil
	end

	def fullname
		@path + @name
	end

	def path=(p)
		if !p.end_with?("/")
			@path = p + "/"
		else
			@path = p
		end
	end
end