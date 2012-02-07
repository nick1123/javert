require 'rubygems'
require 'trollop'

Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }

opts = Trollop::options do
  opt :directory_path, "Where shall I look for files to score? i.e. /home/captain_awesome", :type => :string
  opt :include_file_types, "What types of files shall I include? i.e. rb OR rb|php|txt OR \"\" to include all", :type => :string, :default => "rb"
  opt :exclude_file_types, "What types of files shall I exclude? i.e. log OR log|config|svn OR \"\" to exclude none", :type => :string, :default => "log|test|spec"
  opt :verbose, "Do you want lots of output?", :type => :bool, :default => false
end

Trollop::die :directory_path, "must be supplied" if opts[:directory_path].nil?


class DirectoryProcessor
  OUTPUT_DIR = File.expand_path(File.dirname(__FILE__)) + '/output'
  FILE_LIST_PATH = OUTPUT_DIR + '/files_processed.txt'
  
  def self.run(directory_path, include_file_types, exclude_file_types, verbose)
    cmd = create_find_cmd(directory_path, include_file_types, exclude_file_types)
    puts "Running find command => #{cmd}" if verbose
    file_list = create_file_list(cmd)
    write_file_list_to_output_file(file_list)
    puts "List of files to be processed is logged in #{FILE_LIST_PATH}" if verbose
    # puts file_list
    
  end

  def self.write_file_list_to_output_file(file_list)
    File.open(FILE_LIST_PATH, 'w') {|file_handle| file_handle.write(file_list.join("\n"))}
  end
  
  def self.create_file_list(cmd)
    file_list = `#{cmd}`
    return file_list.split("\n")
  end
  
  def self.create_find_cmd(directory_path, include_file_types, exclude_file_types)
    include_file_types = include_file_types.to_s.gsub("|", "\\|")
    exclude_file_types = exclude_file_types.to_s.gsub("|", "\\|")
    grep_calls = []
    grep_calls << "\"#{include_file_types}\""
    grep_calls << "-v \"#{exclude_file_types}\"" if exclude_file_types.size > 0
    grep_calls << '-v "\._"' # My mounted NFS creates these pesky files
    grep_calls_joined = grep_calls.map {|grep_call| "grep #{grep_call}"}.join(" | ")
    cmd = "find #{directory_path} | #{grep_calls_joined}"
    return cmd    
  end
end



DirectoryProcessor.run(opts[:directory_path], opts[:include_file_types], opts[:exclude_file_types], opts[:verbose])
# p FileProcessor.score_file(opts[:directory_path])



=begin
ruby driver.rb -d "/Volumes/ubuntu-dev/grunt/lib/aggregation/generic/accounts/base_account.rb"
ruby driver.rb -d "/Volumes/ubuntu-dev/grunt/lib/aggregation/mdx/base/request"
ruby driver.rb -d "/Volumes/ubuntu-dev/grunt" -i "png|js" -v
ruby driver.rb -d "/Volumes/ubuntu-dev/peon" -i "rake|yml" -v -e ""
ruby driver.rb -d "/Volumes/ubuntu-dev/grunt" -v -e "environment|initializer|spec|routes|boot"
=end