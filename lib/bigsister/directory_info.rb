module BigSister
  class DirectoryInfo
    PROPERTIES = %w(name file_count directory_count).map(&:to_sym).freeze

    PROPERTIES.each { |prop|
      attr_reader prop
    }

    def initialize(data = {})
      @name = data[:name]
      @file_count = data[:file_count]
      @directory_count = data[:directory_count]
    end

    def type
      "directory"
    end
  end
end
