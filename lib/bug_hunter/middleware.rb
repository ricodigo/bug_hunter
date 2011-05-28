module BugHunter
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      response = nil
      begin
        response = @app.call(env)
      rescue StandardError, LoadError, SyntaxError => e
        error = BugHunter::Error.build_from(env, e)
        error.save

        raise e
      end

      response
    end
  end
end
