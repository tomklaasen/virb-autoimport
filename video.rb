class Video
  include Logging

  require 'exif'
  require 'ffprober'
  require 'time'
  require 'fileutils'

  attr_reader :path

  OUTPUT_DIR = "/Users/tkla/Dropbox\ \(Personal\)/VIRB\ takeouts"
  LEADTIME = 45  # seconds before the photo
  DURATION = 60  # how long will the output video be (in seconds)

  def initialize(videopath, photopath, gmetrix_dir)
    @path = videopath
    @photopath = photopath
    @gmetrix_dir = gmetrix_dir
  end

  def creation_time
    File.birthtime(@path)
  end

  def photo_creation_time
    File.birthtime(@photopath)
  end

  def contains_photo?
    photo_creation_time = File.birthtime(@photopath)
    if photo_creation_time < self.creation_time
      return false
    elsif photo_creation_time > self.creation_time + self.duration.to_i
      return false
    else
      return true
    end
  end

  def process

    if contains_photo?
      logger.info "  found in video #{@path}"
      output_path, start_time, duration = cut_around

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
      speeds_subtitles_path = FitThing.new.generate_srt(gmetrix_file_path, start_time, duration)

      # And we add the subtitles from the .srt file to the video
      SubtitleAdder.new.add_subtitles("#{output_path}.MP4", speeds_subtitles_path)

      FileUtils.rm "#{output_path}.MP4"
      FileUtils.mv "subtitled.MP4", "#{output_path}.MP4"
    end
  end

  # Cuts the current video around the photo
  # Returns path of the resulting video, the starting time of that video, and its duration
  def cut_around
    FileUtils.mkdir_p(OUTPUT_DIR)

    output_path = "#{File.join(OUTPUT_DIR, File.basename(@photopath, ".jpg"))}"
    start_time = File.birthtime(@photopath) - LEADTIME

    if !File.exist?("#{output_path}.MP4")
      logger.info "  creating clip..."
      time_in_video = start_time - self.creation_time
      time_in_video = 0 if time_in_video < 0
      cut_video(@path, time_in_video, DURATION, "#{output_path}")
    else
      logger.warn "  clip '#{"#{output_path}.MP4"}' already exists; skipping"
    end

    return output_path, start_time, DURATION
  end

  def duration
    video_stream.duration.to_i
  end

  private

  def cut_video(path, start, duration, output_path)
    flags = "-loglevel error -hide_banner"
    arguments = "-ss #{start} -t #{duration}"
    command = "ffmpeg -i #{escape_path_for_command_line(path)} #{flags} #{arguments} #{escape_path_for_command_line(output_path)}.MP4"
    logger.debug "Issuing command: #{command}"
    system command
  end

  def probe
    @probe ||= Ffprober::Parser.from_file(@path)
  end

  def video_stream
    probe.video_streams[0]
  end

  def escape_path_for_command_line(path)
    output = path.gsub(' ', '\ ')
    output.gsub!('(', '\(')
    output.gsub!(')', '\)')
    output
  end


end
