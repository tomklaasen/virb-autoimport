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

VIRB_PATH = "/Users/tkla/Desktop/VIRB/VIRB-20170802"
OUTPUT_PATH = "/Volumes/VIRB"

# 1. Move all videos and photos from VIRB to removable HD
def move_media_files(origin, destination)

  # 1b. Move all videos and photos from VIRB to removable HD

  FileUtils::mkdir_p destination

  Dir.glob(File.join(origin, '*')).each do |file|
    FileUtils.move file, File.join(destination, File.basename(file))
  end

end

# EXECUTION
origin = File.join(VIRB_PATH, "DCIM/100_VIRB")

# 1a. Delete all .glv files
Dir.glob(File.join(origin, '*.glv')).each do |file|
  File.delete(file)
end

Dir.glob(File.join(origin, '*.jpg')).each do |photopath|
  puts "Photo #{photopath}"
  photo = Medium.new(photopath)

  Dir.glob(File.join(origin, '*.MP4')).each do |videopath|
    video = Medium.new(videopath)

    asterisk = photo.is_in?(video) ? "*" : " "
    puts " Video #{videopath} #{asterisk}"
    if photo.is_in?(video)
      video.cut_around(photo)
    end
  end
end

# 1. Move all videos and photos from VIRB to removable HD
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

if photo.is_in?(video)
  # video.cut_around(photo)
end

# 3. (nice to have) Add FIT information to video
# TODO

# 4. Move videos and photos to archive location
# TODO
