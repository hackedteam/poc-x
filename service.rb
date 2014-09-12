module Service
  extend self

  def list
    @list ||= begin
      Dir['scripts/*\_start.sh'].inject({}) do |h, path|
        name = path.scan(/scripts\/(.*)\_start/)[0][0]
        h[name] = File.read(path).split("\n")[1].scan(/title:\s(.*)/i)[0].try(:first) || name if name and !h[name]
        h
      end
    end
  end

  def exec(name, action, &block)
    script_path = "scripts/#{name}_#{action}.sh"
    raise "Missing script" unless File.exists?(script_path)

    command = "sh #{script_path}"

    if action == 'status'
      em_system(command, &block)
    else
      system(command << " &")
      yield("", 0)
    end
  end

  def em_system(cmd, &block)
    EM.system(cmd) do |output, status|
      block.call(output, status.exitstatus)
    end
  end
end
