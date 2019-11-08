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

  def stub_directories(path, directories)
    directories.each { |directory|
      allow(File).to receive(:directory?).with(directory).and_return(true)
    }
  end

  def stub_files(path, files)
    files.each { |file|
      allow(File).to receive(:directory?).with(file).and_return(false)
    }
  end

  def stub_entries(path, files)
    allow(Dir).to receive(:entries).with(path).and_return(files)
  end

  it "detects list of directories" do
    stub_directories(path, directory_list)
    stub_entries(path, directory_list)
    expect(directories).to be_a(Array)
  end

  it "detects list of files" do
    stub_files(path, file_list)
    stub_entries(path, file_list)
    expect(files).to be_a(Array)
  end

  it "lists only directories" do
    stub_files(path, file_list)
    stub_directories(path, directory_list)
    stub_entries(path, file_list + directory_list)
    expect(directories.size).to eq(directory_list.size)
  end

  it "lists only files" do
    stub_files(path, file_list)
    stub_directories(path, directory_list)
    stub_entries(path, file_list + directory_list)
    expect(files.size).to eq(file_list.size)
  end
end
