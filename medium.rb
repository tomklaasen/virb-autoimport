class Medium
  require 'exif'
  require 'ffprober'
  require 'time'
  require 'pp'

  def initialize(path)
    @path = path
  end

  def creation_time
    File.birthtime(@path)
    # if @path.end_with?('.jpg')
    #   pp File.birthtime(@path)
    #   @data ||= Exif::Data.new(@path)
    #   pp @data.date_time
    #   @data.date_time.utc
    # else
    #   pp video_stream.tags[:creation_time]
    #   Time.parse(video_stream.tags[:creation_time]).utc
    # end
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

  def duration
    video_stream.duration.to_i
  end

  private

  def probe
    @probe ||= Ffprober::Parser.from_file(@path)
  end

  def video_stream
    probe.video_streams[0]
  end

end
