require "bigsister/application"

RSpec.describe BigSister do
  let(:opts) { {} }
  let(:application) { BigSister::Application.new(opts) }

  it "has a version number" do
    expect(BigSister::VERSION).not_to be nil
  end

  it "loads configuration file" do
    expect(application.config).to be_a(BigSister::Configuration)
  end

  context "with no configuration files" do
    let(:opts) { { config_paths: ["./.doesnotexist.yml"] } }
    it "raises error with no found configuration files" do
      expect { application }.to raise_error(BigSister::NoConfigurationFound)
    end
  end
end
