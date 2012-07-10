#!/usr/bin/env ruby

unless ARGV.size == 1
  puts "Usage: rd gem_or_plugin"
  exit 1
end

gem_or_plugin = ARGV.shift
search_paths = [
  "#{ENV['PWD']}/doc/plugins",
  '/Library/Ruby/Gems/1.8/doc'
]

search_paths.each do |path|
  path = Dir.glob("#{path}/*#{gem_or_plugin}*").last
  if path && FileTest.directory?(path)
    if FileTest.file?("#{path}/index.html")
      exec("open -a safari #{path}/index.html")
    elsif FileTest.file?("#{path}/rdoc/index.html")
      exec("open -a safari #{path}/rdoc/index.html")
    end
  end
end

puts "Couldn't find any rdoc for '#{gem_or_plugin}' in #{search_paths.join(', ')}."
