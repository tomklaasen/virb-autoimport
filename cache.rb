# Load the bundled environment
require "rubygems"
require "bundler/setup"


# Require gems specified in the Gemfile
require 'json'

class Cache
  require_relative 'logging'
  include Logging


  def initialize(basedir, filename)
  	@basedir = basedir
  	@filename = filename
  	@jsonfile = File.join(@basedir, @filename)
  end

  def fetch(key, &block)
	  result = get(key)
	  unless result
	    result = block.call
	    put(key, result)
	  end
	  result
  end

  def fetch_time(key, &block)
    s = fetch(key, &block)
    if s.is_a? String
      Time.parse(fetch(key, &block))
    else
      s
    end
  end

  def get(key)
  	@jsondata ||= load_from_file
  	@jsondata[key]
  end

  def put(key, value)
  	@jsondata ||= {}
  	@jsondata[key] = value
  	save_to_file(@jsondata)
  end

  def load_from_file
  	if File.exist?(@jsonfile)
  		JSON.load(File.new(@jsonfile))
  	else
  		{}
  	end
  end

  def save_to_file(data)
  	File.open(@jsonfile,"w") do |f|
  		f.write(data.to_json)
	  end
  end

end
