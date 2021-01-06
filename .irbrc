begin
  require 'amazing_print'
  AmazingPrint.irb!
rescue LoadError; end

IRB.conf[:SAVE_HISTORY] = 1000
