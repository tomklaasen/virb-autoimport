# Load the bundled environment
require "rubygems"
require "bundler/setup"

require_relative '../cache'
require "test/unit"

DIRECTORY = "sample_data/DCIM/102_VIRB"
FILENAME = "test.json"

class CacheTest < Test::Unit::TestCase

	def test_put
		cache = Cache.new(DIRECTORY, FILENAME)
		cache.put('just_a_key', 'aha')
		assert_equal(cache.get('just_a_key'), 'aha')
	end

	def teardown
		File.delete(File.join(DIRECTORY, FILENAME))
	end
end