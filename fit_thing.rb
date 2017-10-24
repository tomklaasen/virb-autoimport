# Load the bundled environment
require "rubygems"
require "bundler/setup"

# Require gems specified in the Gemfile
require 'fit'
require 'json'
require 'time'

class FitThing
  def self.do_stuff
    fit_file = Fit.load_file("/Users/tkla/Desktop/VIRB\ dump\ 20171023/GMetrix/2017-10-17-11-07-13.fit")
    records = fit_file.records
    records.each do |r|
      header = r.header
      # Look for the GPS messages
      if header[:header_type] == 0 && header[:message_type] == 0 && header[:local_message_type] == 12
        utc_timestamp = r.content[:raw_field_6]
        # Apparently, 1989-12-31T00:00:00 is used as 0. That's 631065600 in the Unix epoch
        unix_timestamp = 631065600 + utc_timestamp
        speed_mm_s = r.content[:raw_field_4]
        speed_km_h = speed_mm_s.to_f / 10000*36

          # puts "raw_field_253: #{r.content[:raw_field_253]}"
          # puts "Header       : #{r.header}"
          # puts "Content      : #{r.content}"
          # puts "  position_lat       : #{r.content[:raw_field_1]}"
          # puts "  position_long      : #{r.content[:raw_field_2]}"
          puts "  speed (mm/s)       : #{speed_mm_s}"
          puts "  speed (km/h)       : #{speed_km_h}"
          # puts "  UTC timestamp      : #{utc_timestamp}"
          # puts "  Unix timestamp     : #{unix_timestamp}"
          puts "  ISO 8601 timestamp : #{Time.at(unix_timestamp).strftime("%Y%m%dT%H%M%S%z")}"
          # puts "  timestamp_ms : #{r.content[:raw_field_0]}"
          # puts
      end
    end
    # puts records[0]
    # puts JSON.pretty_generate(records)
    # File.open("tmp/temp.json","w") do |f|
    #   f.write(records.to_json)
    # end
  end
end

FitThing.do_stuff
