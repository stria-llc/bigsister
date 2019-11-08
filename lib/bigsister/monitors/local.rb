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
        File.directory?(file)
      }
    end

    def directories
      Dir.entries(@path).select { |file|
        File.directory?(file)
      }
    end
  end
end
