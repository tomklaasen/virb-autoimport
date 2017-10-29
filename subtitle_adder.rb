class SubtitleAdder
  include Logging

  def add_subtitles(video_path, subtitles_path)
    #ffmpeg -i ~/Dropbox\ \(Personal\)/VIRB\ takeouts/VIRB0653.MP4 -vf subtitles=speeds.srt subtitled.MP4
    #ffmpeg -i ~/Dropbox\ \(Personal\)/VIRB\ takeouts/VIRB0653.MP4 -vf subtitles=speeds.srt:force_style='Alignment=7' subtitled.MP4
    # system "ffmpeg -i ~/Dropbox\\ \\(Personal\\)/VIRB\\ takeouts/VIRB0653.MP4 -vf subtitles=speeds.srt:force_style='Alignment=7' subtitled.MP4"
    video = escape_path_for_command_line(video_path)
    subtitles = escape_path_for_command_line(subtitles_path)
    flags = "-loglevel error -hide_banner"

    system "ffmpeg -i #{video} -vf #{flags} subtitles=#{subtitles}:force_style='Alignment=7' subtitled.MP4"
  end

  def escape_path_for_command_line(path)
    output = path.gsub(' ', '\ ')
    output.gsub!('(', '\(')
    output.gsub!(')', '\)')
    output
  end
end
