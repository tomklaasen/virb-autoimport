module Logging
  # Load the bundled environment
  require "rubygems"
  require "bundler/setup"

  require 'logger'
  require 'config'

  # This is the magical bit that gets mixed into your classes
  def logger
    Logging.logger
  end

  # Global, memoized, lazy initialized instance of a logger
  def self.logger
    unless @logger
      @logger = Logger.new(File.join(Settings.output_dir, "virb_autoimport_#{Time.now.strftime("%Y-%m-%dT%k%M%S")}.log"))
      @logger.level = Logger::DEBUG
    end
    @logger
  end
end
