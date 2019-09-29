require 'stackprof'

module Rack
  module Peephole
    class Middleware
      def initialize(app, options = {})
        @app = app
      end

      def call(env)
        if env['REQUEST_PATH'] == '/peephole/cpu' || env['REQUEST_PATH'] == '/peephole/wall'
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

        StackProf.start(
          mode: mode,
          interval: interval,
          raw: raw,
        )

        sleep profile_time_seconds

        StackProf.stop

        results = StackProf.results
        dump = Marshal.dump(results)

        headers['Content-Length'] = dump.length.to_s
        headers['Content-Type'] = 'application/octet-stream'

        return [200, headers, [dump]]
      rescue => e
        STDERR.puts e
        headers['Content-Length'] = "0"
        return [500, headers, [e]]
      end
    end
  end
end
