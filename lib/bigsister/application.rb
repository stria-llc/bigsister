require "yaml"
require "bigsister/configuration"

module BigSister
  class Application
    DEFAULT_CONFIG_PATHS = ["./.bigsister.yml", "#{Dir.home}/.bigsister/config.yml"].freeze

    attr_reader :configs

    def initialize(opts = {})
      @config_paths = opts[:config_paths] || DEFAULT_CONFIG_PATHS
      @configs = []

      load_config!
    end

    def run
      configs.each { |config|
        config.reporters.each { |reporter|
          config.monitors.each { |monitor|
            if reporter.log_files?
              monitor.files.each { |file|
                reporter.log_file(file)
              }
            end
            if reporter.log_directories?
              monitor.directories.each { |directory|
                reporter.log_directory(directory)
              }
            end
          }
          reporter.render
        }
      }
    end

    private

    def load_config!
      yaml = @config_paths.map { |path|
        File.exists?(path) && YAML.load(File.open(path).read)
      }.select(&:itself).first
      if yaml.nil?
        raise BigSister::NoConfigurationFound.new(@config_paths)
      end
      sisters = yaml.fetch("sisters", [])
      sisters.each { |config|
        @configs.push(Configuration.new(config))
      }
    end
  end
end
