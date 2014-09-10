require 'fileutils'

class FileStream
  attr_accessor :path
  attr_accessor :unique

  def initialize(filename, unique: false)
    self.path = File.join(self.class.base_path, filename)
    self.unique = unique
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
        stream << "data: #{line.strip}\n\n"
      end
    end
  end
end
