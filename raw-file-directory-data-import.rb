require 'logger'
require 'json'

Dir["#{File.dirname(__FILE__)}/lib/**/*.rb"].each { |f| require(f) }

path = ARGV[0]
base_url = ARGV[1]
file_format = ARGV[2]


if ARGV.length != 3
  puts 'Usage ruby raw-file-directory-data-import.rb [Directory Path] [Profile import service base url] [File format]'
  exit
end


puts "Profile import service base url #{base_url}"

Dir[File.join(path, '*')].find_all { |e| File.file?(e) }.each do |item|
  next if %w(. ..).include? item
  begin
    puts "\nProcessing #{item}"
    CSVFileImporter.new(item, file_format, base_url).work
  rescue e
    puts "\n.......ERROR processing #{item}\n#{e}.........."
  ensure
    file.close
  end
end
