# Load the bundled environment
require "rubygems"
require "bundler/setup"

require_relative '../video'
require_relative '../logging'
require "test/unit"

class VideoTest < Test::Unit::TestCase

	def setup
		Config.load_and_set_settings(Config.setting_files("config", "test"))
	end

	def test_initialize
		origin = "sample_data/DCIM/102_VIRB"
		videopath = File.join(origin, "VIRB0659.MP4")
		# photopath = File.join(origin, "VIRB0668.jpg")
		video = Video.new(origin, videopath, nil)
	end


	def test_process
		origin = "sample_data/DCIM/102_VIRB"
		videopath = File.join(origin, "VIRB0667.MP4")
		video = Video.new(origin, videopath, "sample_data/GMetrix")

		photo = Photo.new(File.join(origin, "VIRB0668.jpg"))
		video.process(photo)
	end



end