class Processor
	# Load the bundled environment
	require "rubygems"
	require "bundler/setup"

	# Require gems specified in the Gemfile
	require 'fileutils'
	require 'config'

	require_relative 'logging'
	include Logging

	require_relative 'video'
	require_relative 'photo'
	require_relative 'fit_thing'

	def process(virb_path, output_dir, duration, leadtime, delete_source_files)
		logger.debug "Duration:: #{duration}"

		movie_dirs = ["101_VIRB", "102_VIRB"]
		gmetrix_dir = File.join(virb_path, 'GMetrix')

		movie_dirs.each do |movie_dir|
			origin = File.join(virb_path, "DCIM/#{movie_dir}")

			# Delete all .glv files; we don't need those
			Dir.glob(File.join(origin, '*.glv')).each do |file|
				File.delete(file)
			end

			photos_array = Dir.glob(File.join(origin, '*.jpg'))

			photos_array.reject!{|name| name.end_with?("_processed.jpg")}

			photos_count = photos_array.count
			logger.info "Processing #{photos_count} situations"

			started_at = Time.now

			# For each photo, find the video in which it is, and cut the relevant part
			photos_array.each_with_index do |photopath, index|
				logger.info "*****************************"
				logger.info "Photo #{index + 1}/#{photos_count}: #{photopath}"

				photo = Photo.new(photopath)

				Dir.glob(File.join(origin, '*.MP4')).each do |videopath|
				  logger.debug("Processing video #{videopath}")
				  video = Video.new(origin, videopath, gmetrix_dir)
				  video.process(photo, output_dir, duration, leadtime)
				end

				File.rename(photopath, "#{photopath[0...-4]}_processed.jpg")

				time_spent = Time.now - started_at
				logger.info "Photo #{index + 1}/#{photos_count} processed. Time spent: #{time_spent}s (that's #{time_spent / (index +1)}s / photo)"

			end

			# Delete source files
			if delete_source_files
				# Delete source files
				Dir.glob(File.join(origin, '*')).each do |file|
				  File.delete(file)
				end
			end
		end

	end

end