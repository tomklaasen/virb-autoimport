# Load the bundled environment
require "rubygems"
require "bundler/setup"

require_relative '../exif_thing'
require "test/unit"

# DIRECTORY = "sample_data/DCIM/102_VIRB"

class ExifThingTest < Test::Unit::TestCase
	def test_nothing
		assert_true(true)
	end

	def test_get_data
		origin = DIRECTORY
		photos_array = Dir.glob(File.join(origin, '*.jpg'))
		photos_array.each_with_index do |photopath, index|
			data = Exif::Data.new(IO.read(photopath))   # load from string
			date_time = data.date_time
			date_time.sub!(':', '-')
			date_time.sub!(':', '-')
			timezone = Time.now.strftime('%z')
		end

	end

end
