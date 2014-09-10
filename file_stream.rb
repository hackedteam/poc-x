require 'fileutils'

class FileStream
  attr_accessor :path
  attr_accessor :unique
  attr_accessor :match

  def initialize(filename, options = {})
    self.path = File.join(self.class.base_path, filename)
    self.unique = options[:unique]
    self.match = Regexp.new(options[:match], true) if options[:match]
  end

  def create_if_missing
    File.open(self.path, 'wb') { } unless File.exists?(self.path)
  end

  def self.delete_all
    glob = File.join(base_path, "*")
    Dir[glob].each { |path| FileUtils.rm_f(path) }
  end

  def self.base_path
    File.join(__dir__, 'data')
  end

  def stream(stream)
    create_if_missing

    EventMachine::file_tail(self.path, nil, -1) do |filetail, line|
      if !unique or (unique and @last_line != line)
        @last_line = line

        if !match or (match and line =~ match)
          stream << "data: #{line.strip}\n"
        end
      end
    end
  end
end
