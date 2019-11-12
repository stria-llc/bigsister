require "bigsister/reporter"
require "csv"

module BigSister
  class CsvReporter < BigSister::Reporter
    def initialize(schema, i)
      super(schema, i)
      if !schema.key?("path")
        raise BigSister::InvalidConfiguration.new("CSV Reporter path is required.")
      else
        @outfile_path = schema.fetch("path")
      end
    end

    def csv
      if summary?
        summary
      else
        detail
      end
    end

    def render
      File.open(@outfile_path, "w") { |file|
        file.write(csv)
      }
    end

    protected

    def headers
      @columns.map { |column| column["title"] }.to_csv(row_sep: nil)
    end

    def detail
      rows = file_rows + directory_rows
      data = rows.reject(&:nil?).map { |row|
        row.to_csv(row_sep: nil)
      }
      ([headers] + data).join("\n")
    end

    def summary
      file_count = file_rows.size
      directory_count = directory_rows.size
      data = @columns.map { |column|
        type = column["type"]
        if type == "timestamp"
          current_timestamp
        elsif type == "file_count"
          file_count
        elsif type == "directory_count"
          directory_count
        end
      }.to_csv(row_sep: nil)
      [headers, data].join("\n")
    end
  end
end
