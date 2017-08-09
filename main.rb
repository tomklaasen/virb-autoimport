# Load the bundled environment
require "rubygems"
require "bundler/setup"

# Require gems specified in the Gemfile
require "viddl"
require "viddl/video/clip"
require 'fileutils'
require_relative 'medium'


# PLAN OF ATTACK
#
# 1. Move all videos and photos from VIRB to removable HD
# 2. For each photo:
# 2a. Search to which video the photo belongs
# 2b. Cut video around photo and save
# 3. (nice to have) Add FIT information to video
# 4. Move videos and photos to archive location

# VIRB_PATH = "/Volumes/Untitled"
VIRB_PATH = "/Users/tkla/Desktop/VIRB/VIRB-20170802/"

# EXECUTION
origin = File.join(VIRB_PATH, "DCIM/100_VIRB")

# Delete all .glv files
Dir.glob(File.join(origin, '*.glv')).each do |file|
  File.delete(file)
end

# For each photo, find the video in which it is, and cut the relevant part
Dir.glob(File.join(origin, '*.jpg')).each do |photopath|
  puts "Photo #{photopath}"
  photo = Medium.new(photopath)

  Dir.glob(File.join(origin, '*.MP4')).each do |videopath|
    video = Medium.new(videopath)

    if photo.is_in?(video)
      puts "  found in video #{videopath}"
      video.cut_around(photo)
    end
  end
end


# 3. (nice to have) Add FIT information to video
# TODO

# 4. Move videos and photos to archive location
# TODO

# Delete source files
Dir.glob(File.join(origin, '*')).each do |file|
  # File.delete(file)
end
