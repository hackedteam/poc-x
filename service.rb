module Services; end

class Service
  def self.list
    Services.constants.map { |c| c.to_s.underscore }
  end

  def self.[](name)
    Object.const_get("Services::#{name.camelize}").new
  end

  private

  def em_system(cmd, &block)
    EM.system(cmd) do |output, status|
      block.call(output, status.exitstatus)
    end
  end
end

module Services
  class VirtualInterface < Service
    def start(&block)
      em_system('ifconfig', &block)
    end

    def stop(&block)
      em_system('ifconfig', &block)
    end

    def status(&block)
      em_system('ifconfig en0', &block)
    end
  end

  class IpTables < Service
    def start(&block)
      em_system('ifconfig', &block)
    end

    def stop(&block)
      em_system('ifconfig', &block)
    end

    def status(&block)
      em_system('ifconfig en7', &block)
    end
  end

  class MitmProxy < Service
    def start(&block)
      em_system('ifconfig', &block)
    end

    def stop(&block)
      em_system('ifconfig', &block)
    end

    def status(&block)
      em_system('ifconfig en7', &block)
    end
  end
end
