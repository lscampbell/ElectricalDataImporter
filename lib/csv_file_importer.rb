require 'csv'
require 'fileutils'

# CSV file importer
class CSVFileImporter
  def initialize(file, file_format, base_url)
    @file_name = file
    publisher  = Publisher.new(ImportServiceClient.new(base_url))
    @importer = FileImporterFactory.new(publisher).find(file_format)
  end

  def work
    puts "processing #{@file_name}"
    file = CSV.open(@file_name)
    error = nil
    begin
      file.shift if @importer.header_row?
      @importer.import(file)
    rescue => e
      puts "error processing #{@file_name} - #{e}"
      puts e.backtrace
      STDOUT.flush
      error = true
    ensure
      file.close
      if error
        FileUtils.mv(@file_name, failed_file_path)
      else
        File.delete(@file_name)
      end

    end
  end

  private

  def failed_file_path
    "#{File.dirname(@file_name)}/errors/#{File.basename(@file_name)}"
  end
end