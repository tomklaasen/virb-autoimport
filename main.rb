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
    logger.debug "environment: #{environment}"
    Config.load_and_set_settings(Config.setting_files("config", environment))
  end

  def do_stuff
    logger.debug "Duration:: #{Settings.duration}"

    origin = File.join(virb_path, "DCIM/100_VIRB")

    # Delete all .glv files; we don't need those
    Dir.glob(File.join(origin, '*.glv')).each do |file|
      File.delete(file)
    end

    gmetrix_dir = File.join(virb_path, 'GMetrix')

    # For each photo, find the video in which it is, and cut the relevant part
    Dir.glob(File.join(origin, '*.jpg')).each do |photopath|
      logger.info "Photo #{photopath}"

      Dir.glob(File.join(origin, '*.MP4')).each do |videopath|
        video = Video.new(videopath, photopath, gmetrix_dir)
        video.process
      end
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
