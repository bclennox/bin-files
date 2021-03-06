# Adapted from http://onrails.org/articles/2006/08/30/namespaces-and-rake-command-completion
#
# Save this somewhere, chmod 0755 it, then add
#
#   complete -C path/to/this/script -o default <command>
#
# to your ~/.bashrc, where <command> is one of the Complete::* classes defined in this script.

require 'fileutils'

module Complete

  # Pass in bash's ENV['COMP_LINE'], and this will attempt to instantiate
  # the appropriate class and output the possible completions to standard
  # output. If the command is unsupported, it does nothing.
  def self.execute(line)
    puts const_get(line.split.first.capitalize).new(line)
  rescue NameError => e
  end
end


# Base class for command completers.
class Complete::Base
  attr_accessor :line

  def initialize(line)
    self.line = line
  end

  # Subclasses may return false from this method if they can't provide
  # completions for some reason.
  def ready?
    true
  end

  # If ready?, joins all the matches with a newline, which is what bash
  # expects. Otherwise, returns the empty string.
  def to_s
    ready? ? matches.join("\n") : ''
  end

private

  # Post-processes all the potential matches based on the candidate.
  def matches
    post_process(candidate.empty? ? completions : completions.select { |c| c.start_with?(candidate) })
  end

  # The list of all arguments passed to the command.
  def arguments
    @arguments ||= line.split(/\s+/, -1)[1..-1]
  end

  # The word we're attempting to complete.
  def candidate
    @candidate ||= arguments.last.strip
  end

  # Provides a hook for performing additional processing of the potential matches
  # after the initial search.
  def post_process(possible_completions)
    possible_completions
  end
end


# Provides completions for Rake tasks based on the Rakefile in the current
# directory. The list of tasks is cached in ~/.rake_completions/<expanded/path>/completions
# so you don't need to wait on "rake -T" to run every time you attempt to
# complete. If your tasks change, simply remove that file and it will be
# regenerated the next time you attempt to complete.
class Complete::RubyTask < Complete::Base

  # Returns true if the current directory contains a Rakefile, false if not.
  def ready?
    File.file?(File.join(Dir.pwd, config_file))
  end

  # Returns the list of tasks, caching it if necessary.
  def completions
    cache_tasks unless cached?
    cached_tasks
  end

private

  def cached?
    File.exists?(path)
  end

  def cached_tasks
    File.read(path).lines
  end

  def cache_tasks
    FileUtils.mkpath(File.dirname(path))
    File.open(path, 'w') do |f|
      f.puts normalized_tasks.join("\n")
    end
  end

  def normalized_tasks
    tasks.lines.map do |task|
      task.split(/\s+/)[1]
    end
  end

  def class_name
    self.class.name.split('::').last
  end

  def config_file
    "#{class_name}file"
  end

  def path
    @path ||= File.join(ENV['HOME'], '.completions', Dir.pwd[1..-1], class_name.downcase)
  end

  def tasks
    raise NotImplementedError
  end

  # Handles task namespacing (db:migrate:status). Bash expects the completions
  # to exclude colons already included in the candidate word, so this returns
  # the portions of the string after that.
  def post_process(possible_completions)
    if candidate.include?(':')
      possible_completions.map { |c| c.split(':', candidate.count(':') + 1).last }
    else
      possible_completions
    end
  end
end

class Complete::Rails < Complete::RubyTask
  def ready?
    system('which', '-s', 'rails')
  end

  def tasks
    `bundle exec rails --tasks --all --silent`
  end
end

class Complete::Rake < Complete::RubyTask
  def tasks
    `bundle exec rake --tasks --all --silent`
  end
end

class Complete::Cap < Complete::RubyTask
  def tasks
    `bundle exec cap --tasks --all`
  end
end


### Main ###


Complete.execute(ENV['COMP_LINE'])
