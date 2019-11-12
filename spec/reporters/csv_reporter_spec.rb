require "bigsister/reporters/csv_reporter"
require "bigsister/file_info"
require "bigsister/directory_info"

RSpec.describe BigSister::CsvReporter do
  let(:format) { nil }
  let(:mode) { "write" }
  let(:columns) { nil }
  let(:path) { "/Users/rspec/out.csv" }
  let(:schema) {
    {
      "type" => "csv",
      "path" => path,
      "format" => format,
      "mode" => mode,
      "include" => include,
      "columns" => columns
    }
  }
  let(:file_info) {
    BigSister::FileInfo.new(
      name: "File Name.txt",
      file_size: rand(1..1e8)
    )
  }
  let(:directory_info) {
    BigSister::DirectoryInfo.new(
      name: "Folder Name",
      file_count: rand(1..3),
      directory_count: rand(1..3)
    )
  }
  let(:files) { [file_info] * rand(1..10) }
  let(:directories) { [directory_info] * rand(1..10) }
  let(:reporter) {
    rep = BigSister::CsvReporter.new(schema, 0)
    files.each { |file| rep.log_file(file) }
    directories.each { |dir| rep.log_directory(dir) }
    rep
  }
  let(:csv) { reporter.csv }
  let(:render) { reporter.render }

  def stub_file_write(csv, path)
    file = instance_double(File)
    allow(File).to receive(:open).with(path, "w").and_yield(file)
    allow(file).to receive(:write).with(csv).and_return(csv.size)
  end

  context "summary" do
    let(:format) { "summary" }
    let(:columns) {
      [
        {
          "title" => "Timestamp",
          "type" => "timestamp"
        },
        {
          "title" => "File Count",
          "type" => "file_count"
        },
        {
          "title" => "Directory Count",
          "type" => "directory_count"
        }
      ]
    }
    it "renders CSV" do
      expect(csv).to be_a(String)
    end
    it "renders file" do
      stub_file_write(csv, path)
      expect { render }.not_to raise_error
    end
  end

  context "detail" do
    let(:format) { "detail" }
    let(:columns) {
      [
        {
          "title" => "Timestamp",
          "type" => "timestamp"
        },
        {
          "title" => "Name",
          "type" => "name"
        },
        {
          "title" => "Type",
          "type" => "type"
        }
      ]
    }
    it "renders CSV" do
      expect(csv).to be_a(String)
    end
    it "renders file" do
      stub_file_write(csv, path)
      expect { render }.not_to raise_error
    end
  end
end
