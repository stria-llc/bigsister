require "bigsister/reporters/zoho_analytics_reporter"

RSpec.describe BigSister::ZohoAnalyticsReporter do
  let(:email) { "jdoe@email.com" }
  let(:workspace) { "My Workspace" }
  let(:table) { "My Table" }
  let(:auth_token) { "auth_token" }
  let(:import_type) { "TRUNCATEADD" }
  let(:format) { "summary" }
  let(:columns) {
    [
      {
        "title" => "Timestamp",
        "type" => "timestamp"
      },
      {
        "title" => "Literal",
        "type" => "literal",
        "value" => "Blah"
      }
    ]
  }
  let(:schema) {
    {
      "type" => "zoho-analytics",
      "email" => email,
      "workspace" => workspace,
      "table" => table,
      "auth_token" => auth_token,
      "import_type" => import_type,
      "format" => format,
      "columns" => columns
    }
  }
  let(:reporter) { BigSister::ZohoAnalyticsReporter.new(schema, 0) }

  def stub_zoho_request(reporter)
    multipart_double = instance_double(Net::HTTP::Post::Multipart)
    uri_double = instance_double(URI::HTTPS)
    allow(uri_double).to receive(:host).and_return("host")
    allow(uri_double).to receive(:port).and_return("port")
    allow(uri_double).to receive(:path).and_return("/")
    http_double = instance_double(Net::HTTP)
    res = instance_double(Net::HTTPSuccess)
    allow(res).to receive(:kind_of?).with(Net::HTTPSuccess).and_return(true)
    allow(http_double).to receive(:request).with(multipart_double).and_return(res)
    io_double = instance_double(UploadIO)
    string_io_double = instance_double(StringIO)
    allow(http_double).to receive(:use_ssl=).with(true)
    allow(reporter).to receive(:zoho_uri).and_return("zoho_uri")
    allow(reporter).to receive(:zoho_rows).and_return([])
    allow(reporter).to receive(:zoho_params).and_return({ "params" => "" })
    allow(URI).to receive(:encode).with("zoho_uri").and_return("encoded_zoho_uri")
    allow(URI).to receive(:parse).with("encoded_zoho_uri").and_return(uri_double)
    allow(Net::HTTP).to receive(:new).with("host", "port").and_return(http_double)
    allow(StringIO).to receive(:new).with("[]").and_return(string_io_double)
    allow(UploadIO).to receive(:new).with(string_io_double, "application/json", "import.json").and_return(io_double)
    allow(Net::HTTP::Post::Multipart).to receive(:new).with("/?params=", "ZOHO_FILE" => io_double).and_return(multipart_double)
  end

  it "adds row to table" do
    stub_zoho_request(reporter)
    expect(reporter.render).to eq(true)
  end

  context "missing email" do
    let(:email) { nil }
    it "raises error" do
      expect { reporter }.to raise_error(BigSister::InvalidConfiguration)
    end
  end

  context "missing auth_token" do
    let(:auth_token) { nil }
    it "raises error" do
      expect { reporter }.to raise_error(BigSister::InvalidConfiguration)
    end
  end

  context "missing workspace" do
    let(:workspace) { nil }
    it "raises error" do
      expect { reporter }.to raise_error(BigSister::InvalidConfiguration)
    end
  end

  context "missing table" do
    let(:table) { nil }
    it "raises error" do
      expect { reporter }.to raise_error(BigSister::InvalidConfiguration)
    end
  end

  context "missing import_type" do
    let(:import_type) { nil }
    it "raises error" do
      expect { reporter }.to raise_error(BigSister::InvalidConfiguration)
    end
  end

  context "invalid import_type" do
    let(:import_type) { "IMPORTTYPE" }
    it "raises error" do
      expect { reporter }.to raise_error(BigSister::InvalidConfiguration)
    end
  end
end
