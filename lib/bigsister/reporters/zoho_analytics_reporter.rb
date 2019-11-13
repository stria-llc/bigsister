require "uri"
require "net/http"
require "net/http/post/multipart"

module BigSister
  class ZohoAnalyticsReporter < BigSister::Reporter
    # TODO: UPDATE action
    IMPORT_ACTIONS = %w(TRUNCATEADD APPEND).freeze

    def initialize(schema, i)
      super(schema, i)
      @email = schema.fetch("email", nil)
      @workspace = schema.fetch("workspace", nil)
      @table = schema.fetch("table", nil)
      @auth_token = schema.fetch("auth_token", nil)
      @import_type = schema.fetch("import_type", nil)
      if @email.nil?
        raise BigSister::InvalidConfiguration.new("Zoho Analytics email is required.")
      elsif @workspace.nil?
        raise BigSister::InvalidConfiguration.new("Zoho Analytics workspace is required.")
      elsif @table.nil?
        raise BigSister::InvalidConfiguration.new("Zoho Analytics table is required.")
      elsif @auth_token.nil?
        raise BigSister::InvalidConfiguration.new("Zoho Analytics auth token is required.")
      elsif @import_type.nil?
        raise BigSister::InvalidConfiguration.new("Zoho Analytics import_type is required.")
      elsif !IMPORT_ACTIONS.include?(@import_type)
        raise BigSister::InvalidConfiguration.new("Zoho Analytics import_type must be one of: #{IMPORT_ACTIONS.join(', ')}")
      end
    end

    def render
      uri = URI.parse(URI.encode(zoho_uri))
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      # Body of request
      data = []
      zoho_rows.each { |row|
        h = {}
        @columns.each_with_index { |col, i|
          h[col["title"]] = row[i]
        }
        data.push(h)
      }
      io = UploadIO.new(StringIO.new(data.to_json), "application/json", "import.json")
      path = uri.path + "?#{URI.encode_www_form(zoho_params)}"
      req = Net::HTTP::Post::Multipart.new(path, "ZOHO_FILE" => io)
      res = http.request(req)
      res.kind_of?(Net::HTTPSuccess)
    end

    protected

    def zoho_params
      {
        "authtoken" => @auth_token,
        "ZOHO_API_VERSION" => "1.0",
        "ZOHO_ACTION" => "IMPORT",
        "ZOHO_IMPORT_FILETYPE" => "JSON",
        "ZOHO_IMPORT_TYPE" => @import_type,
        "ZOHO_OUTPUT_FORMAT" => "JSON",
        "ZOHO_ERROR_FORMAT" => "JSON",
        "ZOHO_AUTO_IDENTIFY" => "true",
        "ZOHO_CREATE_TABLE" => "true",
        "ZOHO_ON_IMPORT_ERROR" => "ABORT"
      }
    end

    def zoho_uri
      "https://analyticsapi.zoho.com/api/#{@email}/#{@workspace}/#{@table}"
    end

    def zoho_rows
      if summary?
        [rows]
      else
        rows
      end
    end
  end
end
