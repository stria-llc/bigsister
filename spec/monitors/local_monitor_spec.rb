require "bigsister/file_info"
require "bigsister/directory_info"

RSpec.describe BigSister::LocalMonitor do
  let(:path) { "/Users/rspec" }
  let(:config) {
    {
      "type" => "local",
      "path" => path
    }
  }
  let(:id) { 0 }
  let(:monitor) { BigSister::LocalMonitor.new(config, id) }
  let(:files) { monitor.files }
  let(:directories) { monitor.directories }
  let(:file_list) { ["File 1.pdf", "File 2.jpg", "File 3.png"] }
  let(:directory_list) { ["Folder 1", "Folder 2", "Folder 3"] }
  let(:sub_file_list) { ["Subfile 1.docx", "Subfile 2.tif"] }
  let(:sub_directory_list) { ["Subfolder 1", "Subfolder 2"] }

  def stub_directories(path, directories, sub_files, sub_directories)
    directories.each { |directory|
      dir_path = File.join(path, directory)
      allow(File).to receive(:directory?).with(dir_path).and_return(true)
      sub_files.each { |sub_file|
        allow(File).to receive(:directory?).with(File.join(dir_path, sub_file)).and_return(false)
      }
      sub_directories.each { |sub_directory|
        allow(File).to receive(:directory?).with(File.join(dir_path, sub_directory)).and_return(true)
      }
      sub_entries = sub_files + sub_directories
      allow(Dir).to receive(:entries).with(dir_path).and_return(sub_entries)
    }
  end

  def stub_files(path, files)
    files.each { |file|
      file_path = File.join(path, file)
      allow(File).to receive(:directory?).with(file_path).and_return(false)
      allow(File).to receive(:size).with(file_path).and_return(rand(1e8))
    }
  end

  def stub_entries(path, files)
    allow(Dir).to receive(:entries).with(path).and_return(files)
  end

  it "detects list of directories" do
    stub_directories(path, directory_list, sub_file_list, sub_directory_list)
    stub_entries(path, directory_list)
    expect(directories).to all(be_a(BigSister::DirectoryInfo))
  end

  it "detects list of files" do
    stub_files(path, file_list)
    stub_entries(path, file_list)
    expect(files).to all(be_a(BigSister::FileInfo))
  end

  it "lists only directories" do
    stub_files(path, file_list)
    stub_directories(path, directory_list, sub_file_list, sub_directory_list)
    stub_entries(path, file_list + directory_list)
    expect(directories.size).to eq(directory_list.size)
  end

  it "lists only files" do
    stub_files(path, file_list)
    stub_directories(path, directory_list, sub_file_list, sub_directory_list)
    stub_entries(path, file_list + directory_list)
    expect(files.size).to eq(file_list.size)
  end
end
