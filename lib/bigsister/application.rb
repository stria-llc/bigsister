require "os"
require "yaml"
require "bigsister/configuration"

module BigSister
  class Application
    DEFAULT_CONFIG_PATHS = ["./.bigsister.yml", "~/.bigsister/config.yml"].freeze

    attr_reader :config

    def initialize(opts = {})
      @config_paths = opts[:config_paths] || DEFAULT_CONFIG_PATHS

      load_config!
    end

    def run
    end

    private

    def load_config!
      yaml = @config_paths.map { |path|
        File.exist?(path) && YAML.load(File.open(path).read)
      }.select(&:itself).first
      if yaml.nil?
        raise BigSister::NoConfigurationFound.new(@config_paths)
      end
      @config = Configuration.new(yaml)
    end
  end
end
