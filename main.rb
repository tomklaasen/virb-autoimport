class Main

  # Load the bundled environment
  require "rubygems"
  require "bundler/setup"

  # Require gems specified in the Gemfile
  require 'fileutils'

  require_relative 'logging'
  include Logging

  require_relative 'medium'
  require_relative 'fit_thing'
  require_relative 'subtitle_adder'

  # VIRB_PATH = "/Volumes/Untitled"
  VIRB_PATH = "/Users/tkla/Desktop/VIRB dump 20171027/"

  def do_stuff

    origin = File.join(VIRB_PATH, "DCIM/100_VIRB")

    # Delete all .glv files; we don't need those
    Dir.glob(File.join(origin, '*.glv')).each do |file|
      File.delete(file)
    end


    output_path, start_time, duration = "", Time.now, 0

    # For each photo, find the video in which it is, and cut the relevant part
    Dir.glob(File.join(origin, '*.jpg')).each do |photopath|
      logger.info "Photo #{photopath}"
      photo = Medium.new(photopath)

      Dir.glob(File.join(origin, '*.MP4')).each do |videopath|
        video = Medium.new(videopath)

        if photo.is_in?(video)
          logger.info "  found in video #{videopath}"
          output_path, start_time, duration = video.cut_around(photo)
          logger.debug "photo time : #{photo.creation_time}"
          logger.debug "output_path: #{output_path}"
          logger.debug "start_time : #{start_time}"
          logger.debug "duration   : #{duration}"

          # Now, we need to find the right GMetrix
          gmetrix_dir = File.join(VIRB_PATH, 'GMetrix')
          gmetrix_file_path = nil
          gmetrix_file_creation_time = Time.new(1980, 1,1,12,0,0)

          Dir.glob(File.join(gmetrix_dir, "*.fit")).each do |fit_file_path|
            birthtime = File.birthtime(fit_file_path)
            if birthtime < photo.creation_time && birthtime > gmetrix_file_creation_time
              gmetrix_file_path = fit_file_path
              gmetrix_file_creation_time = birthtime
            end
          end

          logger.debug "gmetrix_file_path : #{gmetrix_file_path}"

          # Then, we generate the .srt file
          speeds_subtitles_path = FitThing.new.generate_srt(gmetrix_file_path, start_time, duration)

          # And we add the subtitles from the .srt file to the video
          SubtitleAdder.new.add_subtitles("#{output_path}.MP4", speeds_subtitles_path)
        end
      end
    end

    # Delete source files
    puts "Do you want to delete the source files? [yN]"
    do_delete = gets.chomp
    if ['y', "Y"].include?(do_delete)
      # Delete source files
      Dir.glob(File.join(origin, '*')).each do |file|
        File.delete(file)
      end
    end
  end
end

Main.new.do_stuff
