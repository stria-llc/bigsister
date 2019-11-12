require "bigsister"
require "bigsister/application"
require "bigsister/configuration"
require "yaml"

RSpec.describe BigSister::Configuration do
  let(:application) { BigSister::Application.new }
  let(:configs) { application.configs }
  let(:config) { application.configs.first }

  def stub_existing_files(contents)
    paths = BigSister::Application::DEFAULT_CONFIG_PATHS
    paths.each { |path|
      allow(File).to receive(:exists?).with(path).and_return(true)
      allow(File).to receive(:open).with(path).and_return(StringIO.new(contents))
    }
  end

  def stub_missing_files
    paths = BigSister::Application::DEFAULT_CONFIG_PATHS
    paths.each { |path|
      allow(File).to receive(:exists?).with(path).and_return(false)
      allow(File).to receive(:open).with(path).and_return(nil)
    }
  end

  context "local monitor configuration" do
    let(:yaml) {
      {
        "sisters" => [
          {
            "monitor" => [
              {
                "type" => "local",
                "path" => "/Users/bigsister/local"
              }
            ]
          }
        ]
      }.to_yaml
    }

    it "loads configuration" do
      stub_existing_files(yaml)
      expect(config).to be_a(BigSister::Configuration)
    end

    it "configuration is valid" do
      stub_existing_files(yaml)
      expect(config.valid?).to eq(true)
    end
  end

  context "invalid monitor" do
    let(:yaml) {
      {
        "sisters" => [
          {
            "monitor" => [
              {
                "type" => "invalid"
              }
            ]
          }
        ]
      }.to_yaml
    }

    it "loads configuration" do
      stub_existing_files(yaml)
      expect(configs).to all(be_a(BigSister::Configuration))
    end

    it "configuration is invalid" do
      stub_existing_files(yaml)
      expect(config.valid?).to eq(false)
    end
  end

  context "no configuration files" do
    it "raises error with no found configuration files" do
      stub_missing_files
      expect { application }.to raise_error(BigSister::NoConfigurationFound)
    end
  end
end
