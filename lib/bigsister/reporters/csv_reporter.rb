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
      rows = super.map { |row| row.to_csv(row_sep: nil) }
      ([headers] + rows).join("\n")
    end

    def summary
      [headers, super.to_csv(row_sep: nil)].join("\n")
    end
  end
end
