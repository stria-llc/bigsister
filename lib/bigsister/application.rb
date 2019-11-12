require "os"
require "yaml"
require "bigsister/configuration"

module BigSister
  class Application
    DEFAULT_CONFIG_PATHS = ["./.bigsister.yml"]

    if OS.windows?
      DEFAULT_CONFIG_PATHS.push("%USERPROFILE%/.bigsister/config.yml")
    else
      DEFAULT_CONFIG_PATHS.push("~/.bigsister/config.yml")
    end

    DEFAULT_CONFIG_PATHS.freeze

    attr_reader :config

    def initialize(opts = {})
      @config_paths = opts[:config_paths] || DEFAULT_CONFIG_PATHS

      load_config!
    end

    def run
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
    end

    private

    def load_config!
      yaml = @config_paths.map { |path|
        File.exists?(path) && YAML.load(File.open(path).read)
      }.select(&:itself).first
      if yaml.nil?
        raise BigSister::NoConfigurationFound.new(@config_paths)
      end
      @config = Configuration.new(yaml)
    end
  end
end
