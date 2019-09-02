# Load the bundled environment
require "rubygems"
require "bundler/setup"

class ExifThing
  	require_relative 'logging'
	include Logging
	
	require 'exif'
	require 'date'
	require 'time'

	def initialize(path)
		@path = path
	end

	def get_data
		Exif::Data.new(IO.read(@path))   # load from string
	end

	def parse(date_time)
		date_time.sub!(':', '-')
		date_time.sub!(':', '-')
		Time.parse("#{date_time} +0200")
	end

	def creation_time
		data = get_data
		puts data.date_time
		parse data.date_time
	end
end

# puts ExifThing.new('sample data/VIRB0784.jpg').creation_time
