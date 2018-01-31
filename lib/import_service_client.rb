require 'rest-client'
class ImportServiceClient
  def initialize(base_url)
    @base_url = base_url
  end

  def post(path, data)
    url = "#{@base_url}#{path}"
    print '.'
    STDOUT.flush
    RestClient.post url, data, {accept: :json, content_type: :json} do |resp, req, result|
      {status: resp.code, body: resp.body}
    end
  end
end