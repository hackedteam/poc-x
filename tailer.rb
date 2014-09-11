class Tailer
  attr_reader :path
  attr_reader :unique
  attr_reader :match
  attr_reader :filename

  # &block is called async
  def initialize(filename, options = {}, &block)
    @filename = filename
    @block = block
    @path = File.join(self.class.base_path, filename)
    @unique = options[:unique]
    @match = Regexp.new(options[:match], true) if options[:match]

    create_if_missing

    @file_tail = EventMachine::file_tail(path, nil, -1) do |filetail, line|
      if !unique or (unique and @last_line != line)
        @last_line = line

        if !match or (match and line =~ match)
          @block.call(line.strip, filename)
        end
      end
    end
  end

  def close
    @file_tail.close unless @file_tail.closed?
  end

  def self.delete_all
    glob = File.join(base_path, "*")
    Dir[glob].each { |path| FileUtils.rm_f(path) }
  end

  def self.base_path
    File.join(__dir__, 'data')
  end

  private

  def create_if_missing
    File.open(path, 'wb') { } unless File.exists?(path)
  end
end
