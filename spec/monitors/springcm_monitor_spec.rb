require "springcm-sdk"
require "bigsister/monitors/springcm"
require "bigsister/file_info"
require "bigsister/directory_info"

RSpec.describe BigSister::SpringcmMonitor do
  let(:path) { "/Test Folder" }
  let(:client_id) { "client_id" }
  let(:client_secret) { "client_secret" }
  let(:data_center) { "uatna11" }
  let(:config) {
    {
      "type" => "springcm",
      "path" => path,
      "client_id" => client_id,
      "client_secret" => client_secret,
      "data_center" => data_center
    }
  }
  let(:id) { 0 }
  let(:monitor) { BigSister::SpringcmMonitor.new(config, id) }
  let(:files) { monitor.files }
  let(:directories) { monitor.directories }

  class Springcm::FakeFolder < Springcm::Folder
    def name; super end
  end

  class Springcm::FakeDocument < Springcm::Document
    def name; super end
    def native_file_size; super end
  end

  class Springcm::FakeResourceList < Springcm::ResourceList
    def total; super end
  end

  let(:fake_folders) {
    folder = instance_double(Springcm::FakeFolder)
    document_list = instance_double(Springcm::FakeResourceList)
    folder_list = instance_double(Springcm::FakeResourceList)
    allow(document_list).to receive(:total).and_return(rand(1e5))
    allow(folder_list).to receive(:total).and_return(rand(1e5))
    allow(folder).to receive(:name).and_return("Folder Name")
    allow(folder).to receive(:documents).and_return(document_list)
    allow(folder).to receive(:folders).and_return(folder_list)
    [folder] * 10
  }
  let(:fake_files) {
    document = instance_double(Springcm::FakeDocument)
    allow(document).to receive(:name).and_return("Document Name.pdf")
    allow(document).to receive(:native_file_size).and_return(rand(1e8))
    [document] * 10
  }

  def stub_client
    client = instance_double(Springcm::Client)
    allow(Springcm::Client).to receive(:new).with(data_center, client_id, client_secret).and_return(client)
    allow(client).to receive(:connect!).and_return(true)
    return client
  end

  def stub_folder_list(folder, folders)
    folder_list = instance_double(Springcm::FakeResourceList)
    allow(folder).to receive(:folders).and_return(folder_list)
    allow(folder_list).to receive(:items).and_return(folders)
    allow(folder_list).to receive(:next).and_return(nil)
    allow_any_instance_of(Springcm::FakeFolder).to receive(:name).and_return("Folder Name")
    return folder_list
  end

  def stub_document_list(folder, documents)
    document_list = instance_double(Springcm::ResourceList)
    allow(folder).to receive(:documents).and_return(document_list)
    allow(document_list).to receive(:items).and_return(documents)
    allow(document_list).to receive(:next).and_return(nil)
    allow_any_instance_of(Springcm::FakeDocument).to receive(:name).and_return("Document Name.pdf")
    return document_list
  end

  def stub_monitored_folder(client)
    folder = instance_double(Springcm::FakeFolder)
    allow(client).to receive(:folder).with(path: path).and_return(folder)
    return folder
  end

  def stub_folders(path, folders)
    client = stub_client
    folder = stub_monitored_folder(client)
    stub_folder_list(folder, folders)
  end

  def stub_files(path, files)
    client = stub_client
    folder = stub_monitored_folder(client)
    stub_document_list(folder, files)
  end

  it "lists directories" do
    stub_folders(path, fake_folders)
    expect(directories).to all(be_a(BigSister::DirectoryInfo))
  end

  it "lists files" do
    stub_files(path, fake_files)
    expect(files).to all(be_a(BigSister::FileInfo))
  end
end
