class SubtitleAdder
  # Load the bundled environment
  require "rubygems"
  require "bundler/setup"

  # Require gems specified in the Gemfile
  require "viddl"
  require "viddl/video/clip"
  require 'fileutils'
  require_relative 'medium'

  def self.do_your_thing
    #ffmpeg -i ~/Dropbox\ \(Personal\)/VIRB\ takeouts/VIRB0653.MP4 -vf subtitles=subtitle.srt subtitled.MP4

  

  end

  SubtitleAdder.do_your_thing
end
