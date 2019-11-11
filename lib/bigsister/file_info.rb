module BigSister
  class FileInfo
    PROPERTIES = %w(name file_size).map(&:to_sym).freeze

    PROPERTIES.each { |prop|
      attr_reader prop
    }

    def initialize(data = {})
      @name = data[:name]
      @file_size = data[:file_size]
    end

    def type
      "file"
    end
  end
end
