require "bigsister/monitors/local"
require "bigsister/monitors/springcm"

module BigSister
  class Configuration
    MONITOR_TYPES = %w(local springcm).freeze

    attr_reader :monitors

    def initialize(data)
      @monitors = []
      @config_errors = []

      load_monitoring(data)
    end

    def valid?
      @config_errors.empty?
    end

    private

    def load_monitoring(data)
      @monitoring = data.fetch("monitor", [])
      @monitoring.each_with_index { |location, i|
        # Validate monitoring type
        type = location.fetch("type", nil)
        if type.nil?
          config_error("No monitoring type specified for location #{i}")
        elsif !MONITOR_TYPES.include?(type)
          config_error("Invalid monitoring type specified for location #{i}")
        else
          @monitors.push(load_monitor(type, location, i))
        end
      }
    end

    def load_monitor(type, location, i)
      if type == "local"
        BigSister::LocalMonitor.new(location, i)
      elsif type == "springcm"
        BigSister::SpringcmMonitor.new(location, i)
      end
    end

    def config_error(message)
      @config_errors.push(message)
    end
  end
end
