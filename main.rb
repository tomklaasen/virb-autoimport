# Load the bundled environment
require "rubygems"
require "bundler/setup"

# Require gems specified in the Gemfile
require "viddl"
require "viddl/video/clip"

def retrieve_creation_time(photopath)
  File.birthtime(photopath)
end

def retrieve_exif_creation_time(photopath)
  # TODO
end

def cut_video(path, start, duration, output_path)
  options = {:start => start, :duration => duration}
  Viddl::Video::Clip.process path, options
end

lead_time = 15 # seconds before the photo
duration = 30  # how long will the output video be (in seconds)

output_path = "tmp"

photopath = "/Users/tomklaasen/Desktop/VIRB_copy/VIRB_0630.jpg"
videopath = "/Users/tomklaasen/Desktop/VIRB_copy/VIRB_0629.MP4"

phototime = retrieve_creation_time(photopath)
videostart = retrieve_creation_time(videopath)
time_in_video = phototime - videostart

cut_video(videopath, time_in_video - lead_time, duration, output_path) # TODO output_path is ignored
