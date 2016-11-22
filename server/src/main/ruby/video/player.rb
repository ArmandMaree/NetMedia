require "hornetseye_ffmpeg"
require "hornetseye_xorg"
require "hornetseye_alsa"

include Hornetseye

class Player
	def initialize
		@vlcPid = -1
	end

	def play(filename)
		if @vlcPid != -1
			stop
		end

		vlcCommand = "vlc --quiet --play-and-exit #{filename}"
		Thread.new do
			IO.popen("#{vlcCommand} >/dev/null 2>&1") {}
		end
		@vlcPid = getPid(vlcCommand)
	end

	def playFullscreen(filename)
		if @vlcPid != -1
			stop
		end

		vlcCommand = "vlc --fullscreen --quiet --play-and-exit #{filename}"
		Thread.new do
			IO.popen("#{vlcCommand} >/dev/null 2>&1") {}
		end
		@vlcPid = getPid(vlcCommand)
	end

	def getPid(execCommand)
		pipe = IO.popen("ps -ef | grep \"#{execCommand}\"")
		pid = nil
		regex = /.*\d\d:\d\d:\d\d\s+#{Regexp.escape(execCommand)}/
		pipe.readlines.map do |line|
			parts = line.split(/\s+/)

			if line =~ regex
				pid = parts[1].to_i
				break
			end
		end
		pid
	end

	def stop
		if @vlcPid != -1
			Process.kill("INT", @vlcPid)
			@vlcPid = -1
		end
	end
end