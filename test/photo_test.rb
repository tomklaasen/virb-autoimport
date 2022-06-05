# Load the bundled environment
require "rubygems"
require "bundler/setup"

require_relative '../photo'
require "test/unit"

class PhotoTest < Test::Unit::TestCase
	def test_initialize
		photo = Photo.new
		assert_not_nil(photo)
	end
end