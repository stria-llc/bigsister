require "bigsister/monitors/local"
require "bigsister/monitors/springcm"
require "bigsister/reporters/csv_reporter"
require "bigsister/reporters/zoho_analytics_reporter"

module BigSister
  class Configuration
    MONITOR_TYPES = %w(local springcm).freeze
    REPORTER_TYPES = %w(csv zoho-analytics).freeze

    attr_reader :monitors, :reporters

    def initialize(data)
      @monitors = []
      @reporters = []
      @config_errors = []

      load_monitoring(data)
      load_reporting(data)
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

    def load_reporting(data)
      @reporting = data.fetch("report", [])
      @reporting.each_with_index { |reporter, i|
        # Validate reporting type
        type = reporter.fetch("type", nil)
        if type.nil?
          config_error("No report type specified for reporter #{i}")
        elsif !REPORTER_TYPES.include?(type)
          config_error("Invalid report type specifeid for reporter #{i}")
        end
        @reporters.push(load_reporter(type, reporter, i))
        @reporters = @reporters.reject(&:nil?)
      }
    end

    def load_reporter(type, reporter, i)
      if type == "csv"
        BigSister::CsvReporter.new(reporter, i)
      elsif type == "zoho-analytics"
        BigSister::ZohoAnalyticsReporter.new(reporter, i)
      end
    end

    def config_error(message)
      @config_errors.push(message)
    end
  end
end
