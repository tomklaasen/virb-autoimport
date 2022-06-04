# Load the bundled environment
require "rubygems"
require "bundler/setup"

class ExifThing
  	require_relative 'logging'
	include Logging
	
	require 'exif'
	require 'date'
	require 'time'

	def initialize(basedir, path)
		@basedir = basedir
		@path = path
		@cache = Cache.new(basedir, "videos.json")
	end

	def get_data
		Exif::Data.new(IO.read(@path))   # load from string
	end

	def parse(date_time)
		date_time.sub!(':', '-')
		date_time.sub!(':', '-')
		timezone = Time.now.strftime('%z')
		logger.debug "Timezone is #{timezone}"
		#Time.parse("#{date_time} #{timezone}")
		Time.parse("#{date_time} UTC")
	end

	def creation_time
		@cache.fetch_time("#{@path}.creation_time") do		
			data = get_data
			parse(data.date_time)
		end
	end
end

