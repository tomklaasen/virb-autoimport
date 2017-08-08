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

VIRB_PATH = "/Volumes/Untitled"
OUTPUT_PATH = "/Volumes/VIRB"

# 1. Move all videos and photos from VIRB to removable HD
def move_media_files(origin, destination)
  # 1a. Delete all .glv files
  Dir.glob(File.join(origin, '*.glv')).each do |file|
    File.delete(file)
  end

  # 1b. Move all videos and photos from VIRB to removable HD

  FileUtils::mkdir_p destination

  Dir.glob(File.join(origin, '*')).each do |file|
    FileUtils.move file, File.join(destination, File.basename(file))
  end

end

def retrieve_creation_time(path)
  # File.birthtime(path)
  medium = Medium.new(path)
  medium.create_time
end

def cut_video(path, start, duration, output_path)
  options = {:start => start, :duration => duration}
  Viddl::Video::Clip.process path, options
end

lead_time = 15 # seconds before the photo
duration = 30  # how long will the output video be (in seconds)

output_path = "tmp"

# EXECUTION

# 1. Move all videos and photos from VIRB to removable HD
# origin = File.join(VIRB_PATH, "DCIM/100_VIRB")
# tmp = File.join(OUTPUT_PATH, "tmp")
# move_media_files(origin, tmp)

# 2. For each photo:
# 2a. Search to which video the photo belongs
# TODO
# 2b. Cut video around photo and save
# As below. TODO

photopath = "/Users/tkla/Desktop/VIRB/VIRB-20170802/DCIM/100_VIRB/VIRB0653.jpg"
videopath = "/Users/tkla/Desktop/VIRB/VIRB-20170802/DCIM/100_VIRB/VIRB0652-7.MP4"

photo = Medium.new(photopath)
video = Medium.new(videopath)

puts "Photo was taken at #{photo.creation_time}"

puts "Video was taken at #{video.creation_time}"
puts "Video's length is #{video.duration} seconds"

puts "Photo is part of video: #{photo.is_in?(video)}"

# time_in_video = phototime - videostart
#
# cut_video(videopath, time_in_video - lead_time, duration, output_path) # TODO output_path is ignored

# 3. (nice to have) Add FIT information to video
# TODO

# 4. Move videos and photos to archive location
# TODO
