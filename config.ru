require 'logger'
logger = Logger.new(STDOUT)
run do |env|
  logger.debug { "[#{env['HTTP_X_REQUEST_ID']}] #{env['SERVER_PROTOCOL']} #{env['REQUEST_METHOD']} #{env['REQUEST_URI']}" }
  work_time = rand(2)
  sleep(work_time)
  logger.debug { "[#{env['HTTP_X_REQUEST_ID']}] Sending response to #{env['REMOTE_ADDR']}"}
  [200, {}, ["Hello World"]]
end