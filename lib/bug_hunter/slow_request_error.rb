module BugHunter
  class SlowRequestError < StandardError
    def initialize(env, time)
      msg = "Slow request to #{env['REQUEST_URI']} `performed in #{time} seconds'"
      super(msg)
    end
  end
end
