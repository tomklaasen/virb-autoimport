class Medium
  require 'exif'
  require 'ffprober'
  require 'time'
  require 'fileutils'

  attr_reader :path

  OUTPUT_DIR = "/Users/tkla/Dropbox\ \(Personal\)/VIRB\ takeouts"

  def initialize(path)
    @path = path
  end

  def creation_time
    File.birthtime(@path)
  end

  def is_in?(other)
    if self.creation_time < other.creation_time
      return false
    elsif self.creation_time > other.creation_time + other.duration.to_i
      return false
    else
      return true
    end
  end

  # Cuts the current video around the photo
  # Returns path of the resulting video, the starting time of that video, and its duration
  def cut_around(photo)
    lead_time = 45 # seconds before the photo
    duration = 60  # how long will the output video be (in seconds)

    FileUtils.mkdir_p(OUTPUT_DIR)

    output_path = "#{File.join(OUTPUT_DIR, File.basename(photo.path, ".jpg"))}"
    start_time = photo.creation_time - lead_time

    if !File.exist?("#{output_path}.MP4")
      puts "  creating clip..."
      time_in_video = start_time - self.creation_time
      time_in_video = 0 if time_in_video < 0
      cut_video(@path, time_in_video, duration, "'#{output_path}'")
    else
      puts "  clip already exists; skipping"
    end

    return output_path, start_time, duration
  end

  def duration
    video_stream.duration.to_i
  end

  private

  def cut_video(path, start, duration, output_path)
    options = {:start => start, :duration => duration, :output_path => output_path, :flags => "-loglevel error -hide_banner"}
    Viddl::Video::Clip.process path, options
  end

  def probe
    @probe ||= Ffprober::Parser.from_file(@path)
  end

  def video_stream
    probe.video_streams[0]
  end

end
