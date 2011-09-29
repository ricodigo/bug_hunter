module BugHunter
  class Railtie < ::Rails::Railtie
    initializer "bug_hunter.enable_middleware" do |app|
      app.middleware.use "BugHunter::Middleware"
    end
  end
end
