module BigSister
  class Reporter
    def initialize(schema, id)
      @id = id
      @schema = schema
      @files = []
      @directories = []
      if !@schema.key?("format")
        raise BigSister::InvalidConfiguration.new("Reporter format is required")
      elsif !%w(summary detail).include?(@schema.fetch("format"))
        raise BigSister::InvalidConfiguration.new("Reporter format must be one of: summary, detail")
      else
        @format = @schema.fetch("format")
      end
      @columns = schema.fetch("columns", [])
      @columns.each { |column|
        validate_column!(column)
      }
    end

    def log_file(path)
      @files.push(path)
    end

    def log_directory(path)
      @directories.push(path)
    end

    def summary?
      return @format == "summary"
    end

    def detail?
      return !summary?
    end

    def log_files?
      return @schema.fetch("include", []).include?("files")
    end

    def log_directories?
      return @schema.fetch("include", []).include?("directories")
    end

    protected

    def validate_column!(column)
      if !column.key?("type")
        raise BigSister::InvalidConfiguration.new("Column type is required.")
      end
      allowed_types = %w(timestamp literal file_count directory_count)
      if detail?
        allowed_types += %w(file_size type name)
      end
      type = column.fetch("type")
      if !allowed_types.include?(type)
        list = allowed_types.join(", ")
        raise BigSister::InvalidConfiguration.new("Column type for #{@format} must be one of: #{list}")
      end
    end

    def transform_file(file, column)
      type = column["type"]
      if type == "timestamp"
        DateTime.now.strftime("%FT%T%:z")
      elsif type == "name"
        file.name
      elsif type == "type"
        file.type
      elsif type == "file_size"
        file.file_size
      elsif type == "literal"
        @schema.fetch("value", nil)
      end
    end

    def transform_directory(directory, column)
      type = column["type"]
      if type == "timestamp"
        current_timestamp
      elsif type == "name"
        directory.name
      elsif type == "type"
        directory.type
      elsif type == "file_count"
        directory.file_count
      elsif type == "directory_count"
        directory.directory_count
      elsif type == "literal"
        @schema.fetch("value", nil)
      end
    end

    def file_rows
      @files.map { |file|
        @columns.map { |column|
          transform_file(file, column)
        }
      }
    end

    def directory_rows
      @directories.map { |dir|
        @columns.map { |column|
          transform_directory(dir, column)
        }
      }
    end

    def current_timestamp
      DateTime.now.strftime("%FT%T%:z")
    end
  end
end
