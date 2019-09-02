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
    environment = ARGV[0] || 'production'
    Config.load_and_set_settings(Config.setting_files("config", environment))
    logger.debug "environment: #{environment}"
  end

  def do_stuff
    logger.debug "Duration:: #{Settings.duration}"

    origin = File.join(virb_path, "DCIM/101_VIRB")

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
        video = Video.new(videopath, photopath, gmetrix_dir)
        video.process
      end

      File.rename(photopath, "#{photopath}.processed")

      time_spent = Time.now - started_at
      logger.info "Photo #{index + 1}/#{photos_count} processed. Time spent: #{time_spent}s (that's #{time_spent / (index +1)}s / photo)"

    end

    # Delete source files
    puts "Do you want to delete the source files? [yN]"
    do_delete = STDIN.gets.chomp
    if ['y', "Y"].include?(do_delete)
      # Delete source files
      Dir.glob(File.join(origin, '*')).each do |file|
        File.delete(file)
      end
    end
  end

  def virb_path
    Settings.virb_path
  end
end

Main.new.do_stuff
