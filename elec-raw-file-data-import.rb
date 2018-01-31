require 'logger'
require 'json'

Dir["#{File.dirname(__FILE__)}/lib/**/*.rb"].each { |f| require(f) }

full_file_path = ARGV[0]
base_url = ARGV[1]
file_format = ARGV[2]

if ARGV.length != 3
  puts 'Usage ruby elec-raw-file-data-import.rb [Full Path to file] [Base URL] [File format]'
  exit
end

puts "file format is  #{file_format}"
CSVFileImporter.new(full_file_path, file_format, base_url).work
