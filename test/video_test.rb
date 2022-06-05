# Load the bundled environment
require "rubygems"
require "bundler/setup"

require_relative '../video'
require_relative '../logging'
require "test/unit"

class VideoTest < Test::Unit::TestCase
	def test_initialize
		origin = "sample_data/DCIM/102_VIRB"
		videopath = File.join(origin, "VIRB0659.MP4")
		photopath = File.join(origin, "VIRB0668.jpg")
		video = Video.new(origin, videopath, photopath, nil)
	end


end