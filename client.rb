# frozen_string_literal: true

require 'bundler'

Bundler.require(:default, ENV.fetch('APP_ENV', :development))

require 'securerandom'
require 'logger'

$LOAD_PATH.unshift File.dirname(__FILE__)

require 'http_client'
require 'thread_pool'

logger = Logger.new(STDOUT)
client = HttpClient.new
pool = ThreadPool.new(max_workers_count: 1)
pool.await do
  2.times do
    pool.process { client.get_sample_data }
  end
end
