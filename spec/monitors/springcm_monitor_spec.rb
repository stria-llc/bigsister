require "springcm-sdk"
require "bigsister/monitors/springcm"

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
  let(:fake_folders) { [instance_double(Springcm::Folder)] * 10 }
  let(:fake_files) { [instance_double(Springcm::Document)] * 10 }

  def stub_client
    client = instance_double(Springcm::Client)
    allow(Springcm::Client).to receive(:new).with(data_center, client_id, client_secret).and_return(client)
    allow(client).to receive(:connect!).and_return(true)
    return client
  end

  def stub_folder_list(folder, folders)
    folder_list = instance_double(Springcm::ResourceList)
    allow(folder).to receive(:folders).and_return(folder_list)
    allow(folder_list).to receive(:items).and_return(folders)
    allow(folder_list).to receive(:next).and_return(nil)
    return folder_list
  end

  def stub_document_list(folder, documents)
    document_list = instance_double(Springcm::ResourceList)
    allow(folder).to receive(:documents).and_return(document_list)
    allow(document_list).to receive(:items).and_return(documents)
    allow(document_list).to receive(:next).and_return(nil)
    return document_list
  end

  def stub_monitored_folder(client)
    folder = instance_double(Springcm::Folder)
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
    expect(directories).to all(be_a(instance_double(Springcm::Folder).class))
  end

  it "lists files" do
    stub_files(path, fake_files)
    expect(files).to all(be_a(instance_double(Springcm::Document).class))
  end
end
