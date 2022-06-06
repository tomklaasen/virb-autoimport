# Load the bundled environment
require "rubygems"
require "bundler/setup"

require_relative '../video'
require_relative '../logging'
require "test/unit"

class LongVideoTest < Test::Unit::TestCase

	def setup
		Config.load_and_set_settings(Config.setting_files("config", "test"))
		origin = "sample_data/DCIM/102_VIRB"

		remove_old_versions(origin, "VIRB0668", "VIRB0692")
	end

	def remove_old_versions(origin, *basenames)
		basenames.each do |basename|
			if File.exist?(File.join(origin, "#{basename}.jpg.processed"))
				File.rename(File.join(origin, "#{basename}.jpg.processed"), File.join(origin, "#{basename}.jpg"))
			end

			if File.exist?("tmp/#{basename}.MP4")
				File.delete("tmp/#{basename}.MP4")
			end
		end
	end

	def test_process_one_video
		origin = "sample_data/DCIM/102_VIRB"
		videopath = File.join(origin, "VIRB0667.MP4")
		video = Video.new(origin, videopath, "sample_data/GMetrix")

		photo = Photo.new(File.join(origin, "VIRB0668.jpg"))
		video.process(photo)
	end

	def test_process_all_videos
		origin = "sample_data/DCIM/102_VIRB"
		photos_array = Dir.glob(File.join(origin, '*.jpg'))


		# For each photo, find the video in which it is, and cut the relevant part
		photos_array.each_with_index do |photopath, index|
		photo = Photo.new(photopath)

		Dir.glob(File.join(origin, '*.MP4')).each do |videopath|
		  video = Video.new(origin, videopath, "sample_data/GMetrix")
		  video.process(photo)
		end

		File.rename(photopath, "#{photopath}.processed")
		end

	end



end