require "bigsister/monitor"

module BigSister
  class LocalMonitor < BigSister::Monitor
    def initialize(config, i)
      @config = config
      @id = i
      @path = config.fetch("path", nil)
      super(config, i)
    end

    def files
      Dir.entries(@path).reject { |file|
        File.directory?(File.join(@path, file))
      }
    end

    def directories
      Dir.entries(@path).select { |file|
        File.directory?(File.join(@path, file))
      }
    end
  end
end
