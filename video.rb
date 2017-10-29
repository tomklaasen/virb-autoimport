class Video
  include Logging

  require 'exif'
  require 'ffprober'
  require 'time'
  require 'fileutils'

  def initialize(videopath, photopath, gmetrix_dir)
    @videopath = videopath
    @photopath = photopath
    @gmetrix_dir = gmetrix_dir
  end

  def process

    if contains_photo?
      logger.info "  found in video #{@videopath}"

      # Now, we need to find the right GMetrix
      gmetrix_file_path = nil
      gmetrix_file_creation_time = Time.new(1980, 1,1,12,0,0)

      Dir.glob(File.join(@gmetrix_dir, "*.fit")).each do |fit_file_path|
        birthtime = File.birthtime(fit_file_path)
        if birthtime < photo_creation_time && birthtime > gmetrix_file_creation_time
          gmetrix_file_path = fit_file_path
          gmetrix_file_creation_time = birthtime
        end
      end

      logger.debug "gmetrix_file_path : #{gmetrix_file_path}"

      # Then, we generate the .srt file
      @subtitles_path = FitThing.new.generate_srt(gmetrix_file_path, start_time, output_duration)

      # Cut the video
      cut_around

      # And we add the subtitles from the .srt file to the video
      add_subtitles("#{output_path}.MP4")

      FileUtils.rm "#{output_path}.MP4"
      FileUtils.mv "subtitled.MP4", "#{output_path}.MP4"
    end
  end

  def duration
    video_stream.duration.to_i
  end

  private

  def add_subtitles(video_path)
    video = escape_path_for_command_line(video_path)
    subtitles = escape_path_for_command_line(@subtitles_path)
    flags = "-loglevel error -hide_banner"
    command = "ffmpeg -i #{video} #{flags} -vf subtitles=#{subtitles}:force_style='Alignment=7' subtitled.MP4"
    logger.debug "Issuing command: #{command}"
    system command
    FileUtils.rm @subtitles_path
  end

  # Cuts the current video around the photo
  def cut_around
    FileUtils.mkdir_p(output_dir)

    if !File.exist?("#{output_path}.MP4")
      logger.info "  creating clip..."
      time_in_video = start_time - video_creation_time
      time_in_video = 0 if time_in_video < 0
      cut_video(@videopath, time_in_video)
    else
      logger.warn "  clip '#{"#{output_path}.MP4"}' already exists; skipping"
    end
  end

  def cut_video(path, start)
    video = escape_path_for_command_line(path)
    output = "#{escape_path_for_command_line(output_path)}.MP4"
    flags = "-loglevel error -hide_banner"
    arguments = "-ss #{start} -t #{output_duration}"
    command = "ffmpeg -i #{video} #{flags} #{arguments} #{output}"
    logger.debug "Issuing command: #{command}"
    system command
  end

  def probe
    @probe ||= Ffprober::Parser.from_file(@videopath)
  end

  def video_stream
    probe.video_streams[0]
  end

  def video_creation_time
    File.birthtime(@videopath)
  end

  def photo_creation_time
    File.birthtime(@photopath)
  end

  def contains_photo?
    if photo_creation_time < video_creation_time
      return false
    elsif photo_creation_time > video_creation_time + self.duration.to_i
      return false
    else
      return true
    end
  end

  def output_path
    @output_path ||= "#{File.join(output_dir, File.basename(@photopath, ".jpg"))}"
  end

  def start_time
    @start_time ||= File.birthtime(@photopath) - leadtime
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

  def escape_path_for_command_line(path)
    output = path.gsub(' ', '\ ')
    output.gsub!('(', '\(')
    output.gsub!(')', '\)')
    output
  end

end
