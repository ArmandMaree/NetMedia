class Player
	def initialize
		
	end

	def play(filename)
		vlcCommand = "vlc --quiet --play-and-exit #{filename}"
		Thread.new do
			IO.popen("#{vlcCommand} >/dev/null 2>&1") {}
		end
	end

	def playFullscreen(filename)
		vlcCommand = "vlc --fullscreen --play-and-exit #{filename}"
		Thread.new do
			system("date > netmedia-vlc.log") {}
			system("echo 'VLC START' >> netmedia-vlc.log") {}
			system("echo 'vlcCommand: #{vlcCommand}' >> netmedia-vlc.log") {}
			system("#{vlcCommand} >> netmedia-vlc.log") {}
		end
	end

	def stop
		system ("vlc vlc://quit")
	end
end
