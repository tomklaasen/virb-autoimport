# Load the bundled environment
require "rubygems"
require "bundler/setup"

# Require gems specified in the Gemfile
require "viddl"
require "viddl/video/clip"
require 'fileutils'


# PLAN OF ATTACK
#
# 1. copy all videos from VIRB to removable HD
# 2. copy all photos from VIRB to removable HD
# 3. search which photo comes from which video (for each photo)
# 4. cut video around photo and save (for each photo)
# 5. (nice to have) add FIT information to video
# 6. move videos and photos to archive location

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
  File.birthtime(path)
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
origin = File.join(VIRB_PATH, "DCIM/100_VIRB")
tmp = File.join(OUTPUT_PATH, "tmp")
move_media_files(origin, tmp)



# 2. copy all photos from VIRB to removable HD
# TODO

# 3. search which photo comes from which video (for each photo)
# TODO

# 4. cut video around photo and save (for each photo)
# As below. TODO: (for each photo)

photopath = "/Users/tomklaasen/Desktop/VIRB_copy/VIRB_0630.jpg"
videopath = "/Users/tomklaasen/Desktop/VIRB_copy/VIRB_0629.MP4"

phototime = retrieve_creation_time(photopath)
videostart = retrieve_creation_time(videopath)
time_in_video = phototime - videostart

cut_video(videopath, time_in_video - lead_time, duration, output_path) # TODO output_path is ignored

# 5. (nice to have) add FIT information to video
# TODO

# 6. move videos and photos to archive location
# TODO
