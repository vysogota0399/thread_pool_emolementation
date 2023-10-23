# frozen_string_literal: true

require 'thread'

class ThreadPool
  attr_reader :processed

  def initialize(max_workers_count: 10, logger: Logger.new(STDOUT))
    @mutex = Mutex.new
    @worker_cond = ConditionVariable.new
    @global_cond = ConditionVariable.new

    @todo = Queue.new
    @workers = Queue.new
    @scheduled = @processed = @waiting = 0
    @max_workers_count = max_workers_count
    @logger = logger
    spawn_threads
  end

  def await
    @logger.debug { "Start processing thread pool" }
    th = Thread.new do
      yield
      @scheduled = @todo.size

      @mutex.synchronize do
        until @scheduled == @processed
          @global_cond.wait(@mutex)
        end
      end
    end

    th.join
    @logger.debug { "Thread pool is empty, jobs processed #{@processed}/#{@scheduled}" }
  end

  def spawn_threads
    @max_workers_count.times { spawn_thread }
  end

  def spawn_thread
    th = Thread.new do
      todo = @todo
      mutex = @mutex
      cond = @worker_cond
      global_cond = @global_cond
      while true
        work = nil
        mutex.synchronize do
          while todo.empty?
            @waiting += 1
            cond.wait mutex
            @waiting -= 1
          end

          work = todo.pop
        end

        work.call

        mutex.synchronize do
          @processed += 1
          global_cond.signal
        end
      end

      # TODO: kill worker
    end

    @workers << th
    th
  end

  def process(&work)
    @todo << work
    @worker_cond.signal
  end
end

