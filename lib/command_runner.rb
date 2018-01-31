require 'open3'
class CommandRunner
  def initialize(path, base_path, base_url)
    @base_path    = base_path
    @command_line = "ruby elec-raw-file-data-import.rb #{path} #{base_url} #{extract_format(path)}"
  end


  def extract_format(path)
    File.basename(File.dirname(path))
  end

  def run
    puts "command line:  #{@command_line}"
    Open3.popen3(@command_line) do |stdin, stdout, stderr, wait_thr|
      while line = stdout.gets
        puts line
      end
    end

  end

end