class Photo
 	require_relative 'logging'
	include Logging
	
	require 'exif'
	require 'date'
	require 'time'

	attr_accessor :path

	def initialize(path)
		@path = path
	end

	def timestamp
		parse(get_data.date_time)
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

end