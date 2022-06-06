# Load the bundled environment
require "rubygems"
require "bundler/setup"

require_relative '../processor'
require_relative '../logging'
require "test/unit"

class ProcessorTest < Test::Unit::TestCase

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


	def test_process
		Processor.new.process("sample_data", "tmp", 60, 45, false)
	end

end