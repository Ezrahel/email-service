module Providers
  class TransportClient
    attr_reader :provider_config, :base_url

    TIMEOUT_DEFAULT = 10
    OPEN_TIMEOUT_DEFAULT = 5

    def initialize(provider_config)
      @provider_config = provider_config
      @base_url = build_base_url
      @http = build_http_client
    end

    def post(path, body:, headers: {})
      make_request(:post, path, body: body, headers: headers)
    end

    def get(path, params: {}, headers: {})
      make_request(:get, path, params: params, headers: headers)
    end

    def put(path, body:, headers: {})
      make_request(:put, path, body: body, headers: headers)
    end

    def delete(path, headers: {})
      make_request(:delete, path, headers: headers)
    end

    def healthy?
      get("/").success?
    rescue StandardError
      false
    end

    def timeout_ms
      provider_config.settings&.dig("timeout_ms") || TIMEOUT_DEFAULT * 1000
    end

    private

    def build_base_url
      raise NotImplementedError
    end

    def build_http_client
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = OPEN_TIMEOUT_DEFAULT
      http.read_timeout = timeout_ms / 1000
      http.write_timeout = timeout_ms / 1000
      http
    end

    def uri
      @uri ||= URI.parse(base_url)
    end

    def make_request(method, path, body: nil, params: {}, headers: {})
      start = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      request = build_request(method, path, body: body, params: params, headers: headers)
      response = @http.request(request)

      duration = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000).round(2)

      TransportResponse.new(
        status_code: response.code.to_i,
        body: response.body,
        headers: response.to_hash,
        duration_ms: duration
      )
    rescue Net::OpenTimeout => e
      raise Providers::Errors::TimeoutError, "Connection timed out: #{e.message}",
        original_error: e, provider_type: provider_config.provider_type
    rescue Net::ReadTimeout => e
      raise Providers::Errors::TimeoutError, "Read timed out: #{e.message}",
        original_error: e, provider_type: provider_config.provider_type
    rescue Net::WriteTimeout => e
      raise Providers::Errors::TimeoutError, "Write timed out: #{e.message}",
        original_error: e, provider_type: provider_config.provider_type
    rescue Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::EHOSTUNREACH => e
      raise Providers::Errors::ConnectionError, "Connection refused: #{e.message}",
        original_error: e, provider_type: provider_config.provider_type
    rescue SocketError => e
      raise Providers::Errors::ConnectionError, "Socket error: #{e.message}",
        original_error: e, provider_type: provider_config.provider_type
    rescue OpenSSL::SSL::SSLError => e
      raise Providers::Errors::ConnectionError, "SSL error: #{e.message}",
        original_error: e, provider_type: provider_config.provider_type
    end

    def build_request(method, path, body: nil, params: {}, headers: {})
      uri_path = path
      if params.any?
        query = URI.encode_www_form(params)
        uri_path = "#{path}?#{query}"
      end

      klass = case method
              when :post then Net::HTTP::Post
              when :get  then Net::HTTP::Get
              when :put  then Net::HTTP::Put
              when :delete then Net::HTTP::Delete
              else raise ArgumentError, "Unsupported HTTP method: #{method}"
              end

      request = klass.new(uri_path)
      request["Content-Type"] = "application/json"
      request["Accept"] = "application/json"
      request["User-Agent"] = "EmailService-Provider/#{provider_config.provider_type}/1.0"

      headers.each { |k, v| request[k] = v }

      request.body = body.is_a?(String) ? body : body.to_json if body
      request
    end
  end

  class TransportResponse
    attr_reader :status_code, :body, :headers, :duration_ms

    def initialize(status_code:, body:, headers: {}, duration_ms: 0)
      @status_code = status_code
      @body = body
      @headers = headers
      @duration_ms = duration_ms
    end

    def success?
      status_code.between?(200, 299)
    end

    def client_error?
      status_code.between?(400, 499)
    end

    def server_error?
      status_code.between?(500, 599)
    end

    def rate_limited?
      status_code == 429
    end

    def parsed_body
      @parsed_body ||= JSON.parse(body)
    rescue JSON::ParserError
      {}
    end

    def retry_after
      (headers["retry-after"]&.first || headers["Retry-After"]&.first).to_i
    end
  end
end
