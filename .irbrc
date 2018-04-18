begin
  require 'awesome_print'
  AwesomePrint.irb!
rescue LoadError; end

IRB.conf[:SAVE_HISTORY] = 1000
