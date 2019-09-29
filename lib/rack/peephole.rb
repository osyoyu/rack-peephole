require_relative "peephole/version"
require_relative "peephole/middleware.rb"

require 'stackprof'

module Rack
  class Peephole
    def initialize(app, options = {})
      @app = app
      @stackprof_running = false
    end

    def call(env)
      case env['REQUEST_PATH']
      when '/peephole/cpu', '/peephole/wall'
        handle_get_profile(env)
      else
        @app.call(env)
      end
    end

    # GET /peephole/profile/(cpu|wall)
    def handle_get_profile(env)
      params = Rack::Utils.parse_query(env['QUERY_STRING'])
      headers = {}

      mode = env['REQUEST_PATH'].match(%r{^/peephole/(cpu|wall)/?})[1].to_sym
      return [404, headers, []] unless mode

      interval = params['interval'] || 1000
      raw = params['raw'] || false
      profile_time_seconds = params['profile_time_seconds'] || 30

      @stackprof_running = true
      StackProf.start(
        mode: mode,
        interval: interval,
        raw: raw,
      )

      sleep profile_time_seconds

      StackProf.stop
      @stackprof_running = false

      results = StackProf.results
      dump = Marshal.dump(results)

      headers['Content-Length'] = dump.length.to_s
      headers['Content-Type'] = 'application/octet-stream'

      return [200, headers, [dump]]
    rescue => e
      STDERR.puts e
      headers['Content-Length'] = "0"
      return [500, headers, [e]]
    ensure
      @stackprof_running = false
    end
  end
end
