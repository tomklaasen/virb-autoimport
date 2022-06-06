# Load the bundled environment
require "rubygems"
require "bundler/setup"

require_relative '../photo'
require "test/unit"

class PhotoTest < Test::Unit::TestCase
	def setup
		Config.load_and_set_settings(Config.setting_files("config", "test"))
	end

	def teardown
		# Dir.foreach('tmp') do |f|
		#   fn = File.join('tmp', f)
		#   File.delete(fn) if f != '.' && f != '..'
		# end
	end

	def test_initialize
		path = "sample_data/DCIM/102_VIRB/VIRB0668.jpg"
		photo = Photo.new(path)
		assert_not_nil(photo)
		assert_equal(path, photo.path)
	end

	def test_readtime
		path = "sample_data/DCIM/102_VIRB/VIRB0668.jpg"
		photo = Photo.new(path)
		# 28 Feb 2022 at 17:54
		assert_equal('2022-02-28 17:54:18 UTC', photo.timestamp.to_s)
		assert_equal(Time.parse('2022-02-28 17:54:18 UTC'), photo.timestamp)
	end
end