module BugHunter
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      response = nil
      begin
        time = Benchmark.realtime do
          response = @app.call(env)
        end

        if time > 1.0 && env['REQUEST_METHOD'] == 'GET'
          register_error(env, BugHunter::SlowRequestError.new(env, time))
        end
      rescue StandardError, LoadError, SyntaxError => e
        register_error(env, e)
        raise e
      end

      response
    end

    def register_error(env, e)
      error = BugHunter::Error.build_from(env, e)

      if !error.valid? && !error.errors[:uniqueness].empty?
        BugHunter::Error.collection.find(error.unique_error_selector).
                                         update_all({
                                           :$inc => {:times => 1}, 
                                           :$set => {:updated_at => Time.now.utc}
                                         })
      else
        error.save!
      end
    end
  end
end
