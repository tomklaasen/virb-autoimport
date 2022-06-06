# Load the bundled environment
require "rubygems"
require "bundler/setup"


class Video
  require_relative 'logging'
  include Logging

  require_relative 'fit_thing'
  require_relative 'cache'

  # require 'exif'
  require 'ffprober'
  require 'time'
  require 'fileutils'
  require 'mediainfo'

  def initialize(basedir, videopath, gmetrix_dir)
    @basedir = basedir
    @videopath = videopath
    @gmetrix_dir = gmetrix_dir
    @cache = Cache.new(basedir, "videos.json")
  end

  def process(photo)

    if contains_photo?(photo)
      logger.info "  found in video #{@videopath}"

      # Now, we need to find the right GMetrix
      gmetrix_file_path = nil
      gmetrix_file_creation_time = Time.new(1980, 1,1,12,0,0)

      Dir.glob(File.join(@gmetrix_dir, "*.fit")).each do |fit_file_path|
        creation_time = fit_creation_time(fit_file_path)
        if creation_time && creation_time < photo.timestamp && creation_time > gmetrix_file_creation_time
          gmetrix_file_path = fit_file_path
          gmetrix_file_creation_time = creation_time
        end
      end

      logger.debug "gmetrix_file_path : #{gmetrix_file_path}"

      # Then, we generate the .srt file
      if gmetrix_file_path
        @subtitles_path = FitThing.new(@basedir, gmetrix_file_path).generate_srt(start_time, output_duration, output_dir) 
      end

      # Cut the video
      cut_around(photo)

      if gmetrix_file_path
        # And we add the subtitles from the .srt file to the video
        add_subtitles("#{output_path}.MP4")

        FileUtils.rm "#{output_path}.MP4"
        FileUtils.mv subtitled_path, "#{output_path}.MP4"
      end
    end
  end

  def duration
    @cache.fetch("#{@videopath}.duration") {video_stream.duration.to_i}
  end

  def video_creation_time
    @cache.fetch_time("#{@videopath}.video_creation_time") {Time.at(MediaInfo.from(@videopath).video.encoded_date)}
  end

  def fit_creation_time(fit_file_path)
    @cache.fetch_time("#{fit_file_path}.fit_creation_time"){FitThing.new(@basedir, fit_file_path).creation_time}
  end

  private



  def add_subtitles(video_path)
    video = escape_path_for_command_line(video_path)
    subtitles = escape_path_for_command_line(@subtitles_path)
    flags = "-loglevel error -hide_banner"
    command = "ffmpeg -i #{video} #{flags} -vf subtitles=#{subtitles}:force_style='Alignment=7' #{subtitled_path}"
    logger.debug "Issuing command: #{command}"
    system command
    FileUtils.rm @subtitles_path
  end

  # Cuts the current video around the photo
  def cut_around(photo)
    FileUtils.mkdir_p(output_dir)

    if !File.exist?("#{output_path(photo)}.MP4")
      logger.info "  creating clip..."
      time_in_video = start_time(photo) - video_creation_time
      time_in_video = 0 if time_in_video < 0
      cut_video(@videopath, time_in_video, "#{escape_path_for_command_line(output_path(photo))}.MP4")
    else
      logger.warn "  clip '#{"#{output_path(photo)}.MP4"}' already exists; skipping"
    end
  end

  def cut_video(path, start, output_filename)
    video = escape_path_for_command_line(path)
    flags = "-loglevel error -hide_banner"
    arguments = "-ss #{start} -t #{output_duration}"
    command = "ffmpeg -i #{video} #{flags} #{arguments} #{output_filename}"
    logger.debug "Issuing command: #{command}"
    system command
  end

  def probe
    @probe ||= Ffprober::Parser.from_file(@videopath)
  end

  def video_stream
    probe.video_streams[0]
  end

  def contains_photo?(photo)
    if photo.timestamp < video_creation_time
      logger.debug "Video doesn't contain photo; photo was taken at #{photo.timestamp}, before start of video (#{video_creation_time})"
      return false
    elsif photo.timestamp > video_creation_time + self.duration.to_i
      logger.debug "Video doesn't contain photo; photo was taken at #{photo.timestamp}, after end of video (#{video_creation_time + self.duration.to_i})"
      return false
    else
      return true
    end
  end

  def output_path(photo)
    @output_path ||= "#{File.join(output_dir, File.basename(photo.path, ".jpg"))}"
  end

  def start_time(photo)
    @start_time ||= photo.timestamp - leadtime
  end

  def output_duration
    Settings.duration
  end

  def leadtime
    Settings.leadtime
  end

  def output_dir
    Settings.output_dir
  end

  def subtitled_path
    unless @subtitled_path
      tmp_dir = File.join(output_dir, 'tmp')
      FileUtils.mkdir_p(tmp_dir)
      @subtitled_path = File.join(tmp_dir,'subtitled.mp4')
    end

    @subtitled_path 
  end

  def escape_path_for_command_line(path)
    output = path.gsub(' ', '\ ')
    output.gsub!('(', '\(')
    output.gsub!(')', '\)')
    output
  end

end
