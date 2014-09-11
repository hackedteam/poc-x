module Service
  extend self

  def list
    @list ||= Dir['scripts/*\_start.sh'].map { |path| path.scan(/scripts\/(.*)\_start/)[0][0] }.uniq
  end

  def exec(name, action, &block)
    script_path = "scripts/#{name}_#{action}.sh"
    raise "Missing script" unless File.exists?(script_path)

    command = if script_path.end_with?(".sh")
      "sh #{script_path}"
    elsif script_path.end_with?(".rb")
      "ruby #{script_path}"
    else
      "./#{script_path}"
    end

    em_system(command, &block)
  end

  def em_system(cmd, &block)
    EM.system(cmd) do |output, status|
      block.call(output, status.exitstatus)
    end
  end
end
