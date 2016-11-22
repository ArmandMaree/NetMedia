require "hornetseye_ffmpeg"
require "hornetseye_xorg"
require "hornetseye_alsa"

include Hornetseye

class Player
	def initialize

	end

	def play(filename)
		input = AVInput.new filename
		X11Display.show(600, :frame_rate => input.frame_rate) {
			input.read
		}
	end
end