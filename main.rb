# Load the bundled environment
require "rubygems"
require "bundler/setup"

# Require gems specified in the Gemfile
require "viddl"
require "viddl/video/clip"

def cut_video(path, start, duration)
  options = {:start => start, :duration => duration}
  Viddl::Video::Clip.process path, options
end


cut_video('/Users/tomklaasen/Desktop/VIRB\ copy/VIRB_0629.MP4', 268, 30)
