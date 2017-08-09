class FitThing
  require 'fit-parser'
  def self.do_stuff
    fit_file = Fit.load_file("/Users/tkla/Desktop/VIRB/VIRB-20170802/GMetrix/2017-08-02-09-27-10.fit")
    records = fit_file.records.select{ |r| r.content.record_type != :definition }.map{ |r| r.content }
  end
end

FitThing.do_stuff
