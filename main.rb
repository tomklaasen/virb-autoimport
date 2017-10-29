class Main

  # Load the bundled environment
  require "rubygems"
  require "bundler/setup"

  # Require gems specified in the Gemfile
  require 'fileutils'

  require_relative 'logging'
  include Logging

  require_relative 'video'
  require_relative 'fit_thing'

  # VIRB_PATH = "/Volumes/Untitled"
  VIRB_PATH = "/Users/tkla/Desktop/VIRB dump 20171027/"

  def do_stuff

    origin = File.join(VIRB_PATH, "DCIM/100_VIRB")

    # Delete all .glv files; we don't need those
    Dir.glob(File.join(origin, '*.glv')).each do |file|
      File.delete(file)
    end

    gmetrix_dir = File.join(VIRB_PATH, 'GMetrix')

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
