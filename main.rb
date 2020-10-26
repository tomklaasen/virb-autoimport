class Main

  # Load the bundled environment
  require "rubygems"
  require "bundler/setup"

  # Require gems specified in the Gemfile
  require 'fileutils'
  require 'config'

  require_relative 'logging'
  include Logging

  require_relative 'video'
  require_relative 'fit_thing'

  def initialize
    # Argument parser taken from accepted answer on https://stackoverflow.com/questions/26434923/parse-command-line-arguments-in-a-ruby-script
    args = { :environment => 'production' } # Setting default values
    unflagged_args = [ :environment ]       # Bare arguments (no flag)
    next_arg = unflagged_args.first
    ARGV.each do |arg|
      case arg
        when '--virb_path'     then next_arg = :virb_path
        when '--loglevel'      then next_arg = :loglevel
      else
        if next_arg
          args[next_arg] = arg
          unflagged_args.delete( next_arg )
        end
        next_arg = unflagged_args.first
      end
    end


    environment = args[:environment]
    Config.load_and_set_settings(Config.setting_files("config", environment))

    if args[:loglevel]
      logger.level = args[:loglevel]
    end

    logger.debug "environment: #{environment}"

    @virb_path = args[:virb_path]

    logger.debug "virb_path is #{virb_path}"
  end

  def do_stuff
    logger.debug "Duration:: #{Settings.duration}"

    movie_dirs = ["101_VIRB", "102_VIRB"]

    movie_dirs.each do |movie_dir|
      origin = File.join(virb_path, "DCIM/#{movie_dir}")


      # Delete all .glv files; we don't need those
      Dir.glob(File.join(origin, '*.glv')).each do |file|
        File.delete(file)
      end

      gmetrix_dir = File.join(virb_path, 'GMetrix')

      photos_array = Dir.glob(File.join(origin, '*.jpg'))

      photos_count = photos_array.count
      logger.info "Processing #{photos_count} situations"

      started_at = Time.now

      # For each photo, find the video in which it is, and cut the relevant part
      photos_array.each_with_index do |photopath, index|
        logger.info "*****************************"
        logger.info "Photo #{index + 1}/#{photos_count}: #{photopath}"

        Dir.glob(File.join(origin, '*.MP4')).each do |videopath|
          logger.debug("Processing video #{videopath}")
          video = Video.new(origin, videopath, photopath, gmetrix_dir)
          video.process
        end

        File.rename(photopath, "#{photopath}.processed")

        time_spent = Time.now - started_at
        logger.info "Photo #{index + 1}/#{photos_count} processed. Time spent: #{time_spent}s (that's #{time_spent / (index +1)}s / photo)"

      end

      # Delete source files
      if delete_source_files?
        # Delete source files
        Dir.glob(File.join(origin, '*')).each do |file|
          File.delete(file)
        end
      end
    end
  end

  def delete_source_files?
    resultstring = Settings.delete_source_files
    if resultstring.nil?
      puts "Do you want to delete the source files? [yN]"
      resultstring = STDIN.gets.chomp
    end
    ['y', "Y"].include?(resultstring)
  end
  
  def virb_path
    @virb_path ||= Settings.virb_path
  end
end

Main.new.do_stuff
