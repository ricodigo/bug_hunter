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

        if !error.valid? && !error.errors[:uniqueness].empty?
          BugHunter::Error.collection.update(error.unique_error_selector, {:$inc => {:times => 1}})
        else
          error.save
        end

        raise e
      end

      response
    end
  end
end
