require 'listen'
require_relative 'lib/command_runner'

unless ARGV.length == 2
  puts 'Usage ruby file-watch.rb [Path to Watch] [import service url]'
  exit
end

listen_path = ARGV[0]
base_url    = ARGV[1]


listener = Listen.to(listen_path) do |modified, added, removed|
  added.each do |path|
    CommandRunner.new(path, listen_path, base_url).run
  end

end

listener.start
listener.ignore /errors/
sleep