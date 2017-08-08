class Medium
  require 'exif'
  require 'ffprober'
  require 'time'
  require 'fileutils'

  attr_reader :path

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

  def cut_around(photo)
    lead_time = 45 # seconds before the photo
    duration = 60  # how long will the output video be (in seconds)

    output_folder = "tmp"
    FileUtils.mkdir_p(output_folder)

    output_path = File.join(output_folder, File.basename(photo.path, ".jpg"))

    time_in_video = photo.creation_time - self.creation_time - lead_time
    time_in_video = 0 if time_in_video < 0
    cut_video(@path, time_in_video, duration, output_path) # TODO output_path is ignored
  end

  def duration
    video_stream.duration.to_i
  end

  private

  def cut_video(path, start, duration, output_path)
    options = {:start => start, :duration => duration, :output_path => output_path}
    Viddl::Video::Clip.process path, options
  end

  def probe
    @probe ||= Ffprober::Parser.from_file(@path)
  end

  def video_stream
    probe.video_streams[0]
  end

end
