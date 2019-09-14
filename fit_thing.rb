# Load the bundled environment
require "rubygems"
require "bundler/setup"


# Require gems specified in the Gemfile
require 'fit'
require 'json'
require 'time'
require 'fileutils'

class FitThing
  require_relative 'logging'
  include Logging


  def initialize(basedir, file_path)
    @basedir = basedir
    @gmetrix_file_path = file_path
    @cache = Cache.new(basedir, "videos.json")
  end

  def generate_srt(start_time, duration, output_directory)
    tmp_dir = File.join(output_directory, 'tmp')
    FileUtils.mkdir_p(tmp_dir)
    output_path = File.join(tmp_dir,'speeds.srt')

    # logger.debug "gmetrix_file_path     : #{@gmetrix_file_path}"
    # logger.debug "start_time            : #{start_time}"
    # logger.debug "duration              : #{duration}"
    # logger.debug "start_time + duration : #{start_time + duration}"

    end_time = start_time + duration

    counter = 0
    File.open(output_path, 'w') do  |file|
      # Initialize the file (so we have something in there in case no gpx records are found)
      file.write("#{counter + 1}\n")
      start = "#{FitThing.counter_to_time_string(counter)},001"
      stop = "#{FitThing.counter_to_time_string(counter)},002"
      file.write("#{start} --> #{stop}\n")
      file.write(" \n\n")
      counter += 1

      fit_file = Fit.load_file(@gmetrix_file_path)
      records = fit_file.records
      records.each do |r|
        header = r.header

        # Look for the GPS messages
        if header[:header_type] == 0 && header[:message_type] == 0 && header[:local_message_type] == 12
          # logger.debug "GPS message found"
          utc_timestamp = r.content[:raw_field_6]
          if utc_timestamp
            # Apparently, 1989-12-31T00:00:00 is used as 0. That's 631065600 in the Unix epoch
            unix_timestamp = 631065600 + utc_timestamp

            # logger.debug " timestamp : #{Time.at(unix_timestamp)}"
            # logger.debug " start_time: #{start_time}"
            # logger.debug " end_time  : #{end_time}"

            if (Time.at(unix_timestamp) >= start_time) && (Time.at(unix_timestamp) <= end_time)
              # logger.debug " ... and it's in the specified interval"
              speed_mm_s = r.content[:raw_field_4]
              speed_km_h = speed_mm_s.to_f / 10000*36

              file.write("#{counter + 1}\n")
              start = "#{FitThing.counter_to_time_string(counter)},001"
              stop = "#{FitThing.counter_to_time_string(counter+1)},000"
              file.write("#{start} --> #{stop}\n")
              file.write("#{Time.at(unix_timestamp).strftime("%Y-%m-%d %H:%M:%S")}        #{speed_km_h.round(1)} km/h\n\n")

              counter += 1
            end
          end

          # puts "raw_field_253: #{r.content[:raw_field_253]}"
          # puts "  position_lat       : #{r.content[:raw_field_1]}"
          # puts "  position_long      : #{r.content[:raw_field_2]}"
        end
      end
    end
    return output_path
  end

  def self.counter_to_time_string(counter)
    seconds = counter % 60
    minutes = counter / 60
    hours = minutes / 60
    minutes = minutes % 60

    "#{'%02d' % hours}:#{'%02d' % minutes}:#{'%02d' % seconds}"
  end

  def creation_time
    @cache.fetch_time("#{@gmetrix_file_path}.creation_time") do 
      fit_file = Fit.load_file(@gmetrix_file_path)
      records = fit_file.records
      records.each do |r|
          header = r.header

          # Look for the GPS messages
          if header[:header_type] == 0 && header[:message_type] == 0 && header[:local_message_type] == 0
            utc_timestamp = r.content[:raw_time_created]
            if utc_timestamp
              # Apparently, 1989-12-31T00:00:00 is used as 0. That's 631065600 in the Unix epoch
              unix_timestamp = 631065600 + utc_timestamp
              return Time.at(unix_timestamp)
            end

          end
      end
      return nil
    end
  end

end
