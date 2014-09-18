class Tailer
  attr_reader :path
  attr_reader :unique
  attr_reader :match
  attr_reader :filename
  attr_reader :format_params

  # &block is called async
  def initialize(filename, options = {}, &block)
    @filename = filename
    @block = block
    @path = File.join(self.class.base_path, filename)
    @unique = options[:unique]
    @match = Regexp.new(options[:match], true) if options[:match]
    @format_params = options[:format_params] || options[:formatParams]

    create_if_missing

    @file_tail = EventMachine::file_tail(path, nil, -1) do |filetail, line|
      if !unique or (unique and @last_line != line)
        if !match or (match and line =~ match)
          @last_line = line
          line = " > " + line.gsub!("&", "\n> ") if format_params and line =~ /\=.+(\&.+\=)+/
          @block.call(line.strip, filename)
        end
      end
    end
  end

  def close
    @file_tail.close unless @file_tail.closed?
  end

  def self.truncate_all
    glob = File.join(base_path, "*")
    Dir[glob].each { |path| File.open(path, 'wb') {} }
  end

  def self.base_path
    File.join(File.dirname(File.realpath(__FILE__)), 'data')
  end

  private

  def create_if_missing
    File.open(path, 'wb') { } unless File.exists?(path)
  end
end
