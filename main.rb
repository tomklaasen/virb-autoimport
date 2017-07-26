# Load the bundled environment
require "rubygems"
require "bundler/setup"

# Require gems specified in the Gemfile
require "viddl"
require "viddl/video/clip"

def retrieve_time(photopath)
  File.birthtime(photopath)
end

def cut_video(path, start, duration)
  options = {:start => start, :duration => duration}
  Viddl::Video::Clip.process path, options
end


phototime = retrieve_time('/Users/tomklaasen/Desktop/VIRB copy/VIRB_0630.jpg')
puts phototime
# cut_video('/Users/tomklaasen/Desktop/VIRB\ copy/VIRB_0629.MP4', phototime - 15, 30)
