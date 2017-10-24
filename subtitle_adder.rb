class SubtitleAdder
  # Load the bundled environment
  require "rubygems"
  require "bundler/setup"

  def self.do_your_thing
    #ffmpeg -i ~/Dropbox\ \(Personal\)/VIRB\ takeouts/VIRB0653.MP4 -vf subtitles=speeds.srt subtitled.MP4
    #ffmpeg -i ~/Dropbox\ \(Personal\)/VIRB\ takeouts/VIRB0653.MP4 -vf subtitles=speeds.srt:force_style='Alignment=7' subtitled.MP4
    system "ffmpeg -i ~/Dropbox\\ \\(Personal\\)/VIRB\\ takeouts/VIRB0653.MP4 -vf subtitles=speeds.srt:force_style='Alignment=7' subtitled.MP4"
  end

  SubtitleAdder.do_your_thing
end
