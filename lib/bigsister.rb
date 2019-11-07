require "bigsister/version"

module BigSister
  class Error < StandardError
    def initialize(exception)
      @exception = exception
    end

    def message
      @exception
    end

    def inspect
      %(#<#{self.class} @exception=#{@exception}>)
    end
  end

  class NoConfigurationFound < Error
    def initialize(checked_paths)
      super("No configuration files found. Looked in: #{checked_paths.join(', ')}")
    end
  end
end
