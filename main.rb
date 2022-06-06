class Main

  # Load the bundled environment
  require "rubygems"
  require "bundler/setup"

  # Require gems specified in the Gemfile
  require 'fileutils'
  require 'config'

  require_relative 'logging'
  include Logging

  require 'processor'

  def initialize
    # Argument parser taken from accepted answer on https://stackoverflow.com/questions/26434923/parse-command-line-arguments-in-a-ruby-script
    args = { :environment => 'production' } # Setting default values
    unflagged_args = [ :environment ]       # Bare arguments (no flag)
    next_arg = unflagged_args.first
    ARGV.each do |arg|
      case arg
        when '--virb_path'     then next_arg = :virb_path
        when '--loglevel'      then next_arg = :loglevel
      else
        if next_arg
          args[next_arg] = arg
          unflagged_args.delete( next_arg )
        end
        next_arg = unflagged_args.first
      end
    end


    environment = args[:environment]
    Config.load_and_set_settings(Config.setting_files("config", environment))

    if args[:loglevel]
      logger.level = args[:loglevel]
    end

    logger.debug "environment: #{environment}"

    @virb_path = args[:virb_path]

    logger.debug "virb_path is #{virb_path}"
  end

  def do_stuff
    Processor.new.process(Settings.virb_path, Settings.output_dir, Settings.duration, Settings.leadtime, delete_source_files?)
  end

  def delete_source_files?
    resultstring = Settings.delete_source_files
    if resultstring.nil?
      puts "Do you want to delete the source files? [yN]"
      resultstring = STDIN.gets.chomp
    end
    ['y', "Y"].include?(resultstring)
  end
  
end

Main.new.do_stuff
