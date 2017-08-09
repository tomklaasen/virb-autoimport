# Load the bundled environment
require "rubygems"
require "bundler/setup"

# Require gems specified in the Gemfile
require 'fit'
require 'json'
require 'time'

class FitThing
  def self.do_stuff
    fit_file = Fit.load_file("/Users/tkla/Desktop/VIRB/VIRB-20170802/GMetrix/2017-07-28-12-17-43.fit")
    # fit_file = Fit.load_file("/Users/tkla/Desktop/VIRB/VIRB-20170802/GMetrix/2017-08-02-09-27-10.fit")
    # records = fit_file.records.select{ |r| r.content.record_type != :definition }.map{ |r| r.content }
    records = fit_file.records
    records.each do |r|
      header = r.header
      # Look for the GPS messages
      if header[:header_type] == 0 && header[:message_type] == 0 && header[:local_message_type] == 12
        # Take one (for research purposes)
        # In CSV (extracted with FIT SDK), this looks like
        # Data,12,gps_metadata,timestamp,"205",s,position_lat,"610354599",semicircles,position_long,"52414043",semicircles
        # ,enhanced_altitude,"4.800000000000011",m,enhanced_speed,"6.585",m/s,utc_timestamp,"870171662",s,timestamp_ms,"821",ms
        # ,heading,"347.55",degrees,velocity,"-1.41|6.43|0.18",m/s,unknown,"3",,unknown,"6",,unknown,"7",,unknown,"110",,unknown
        # ,"70",,,,,,,,,,,,,,,,,,,,
        if r.content[:raw_field_253] == 205
          puts "Header : #{r.header}"
          puts "Content: #{r.content}"
          puts "  position_lat  : #{r.content[:raw_field_1]}"
          puts "  position_long : #{r.content[:raw_field_2]}"
          puts "  speed (mm/s)  : #{r.content[:raw_field_4]}"
          utc_timestamp = r.content[:raw_field_6]
          puts "  UTC timestamp : #{utc_timestamp}"
          # Apparently, 1989-12-31T00:00:00 is used as 0. That's 631065600 in the Unix epoch
          unix_timestamp = 631065600 + utc_timestamp
          puts "  Unix timestamp: #{unix_timestamp}"
          puts "  ISO timestamp : #{Time.at(unix_timestamp).strftime("%Y%m%dT%H%M%S%z")}"
          puts "  timestamp_ms : #{r.content[:raw_field_0]}"
        end
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
