# frozen_string_literal: true

require 'benchmark'

class HttpClient
  attr_reader :config, :logger, :default_headers

  IDEMPOTENT_REQUESTS = %w[HEAD OPTIONS GET PUT TRACE DELETE]

  def initialize(config: default_config, logger: default_logger)
    @config = config
    @logger = default_logger
    @default_headers = {}
    @mutex = Mutex.new
    @attempts = {}
  end

  def get_sample_data
    send_request('get', '/')
  end

  private

  def client
    @client ||= begin
      client = HTTPClient.new(base_url: config[:base_url])
      client.connect_timeout = config[:connect_timeout]
      client.send_timeout = config[:send_timeout]
      client.receive_timeout = config[:receive_timeout]
      client
    end
  end

  def send_request(method, uri, body = {}, query = {}, headers = {})
    request_uuid = SecureRandom.uuid
    headers = default_headers.merge(headers).merge('X-Request-ID' => request_uuid)
    logger.debug { "[#{request_uuid}] Send #{method.upcase} #{uri}" }
    logger.debug { "[#{request_uuid}] Headers #{headers}" }
    logger.debug { "[#{request_uuid}] Params: #{body} #{query}" } if body.any? || query.any?
    message = nil
    request_duration = 
      Benchmark.measure do
        message = client.request(method, uri, body: body, query: query, header: headers)
      end
    content = message.content
    logger.debug { "[#{request_uuid}] Response #{message.status} #{content}" }
    logger.debug { "[#{request_uuid}] Duration: #{request_duration.real} seconds" }
    content
  rescue HTTPClient::ReceiveTimeoutError
    logger.error { "[#{request_uuid}] Execution expired" }
  end

  def default_config
    {
      connect_timeout: 5,
      send_timeout: 5,
      receive_timeout: 1,
      base_url: 'http://server:3000',
      retries_count: 1,
    }
  end

  def default_logger
    Logger.new(STDOUT)
  end
end