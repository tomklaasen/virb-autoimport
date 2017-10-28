module Logging
  require 'logger'

  # This is the magical bit that gets mixed into your classes
  def logger
    Logging.logger
  end

  # Global, memoized, lazy initialized instance of a logger
  def self.logger
    unless @logger
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::DEBUG
    end
    @logger
  end
end
