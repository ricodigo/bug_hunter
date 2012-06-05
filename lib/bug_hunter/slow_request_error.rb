module BugHunter
  class SlowRequestError < StandardError
    def initialize(env, time)
      msg = "Slow request #{env['REQUEST_URI']}"
      env['X-TIME'] = "performed in #{time} seconds"
      super(msg)
    end
  end
end
