module BugHunter
  class App < Sinatra::Base
    include BugHunter::UiHelper
    include BugHunter::RoutesHelper

    helpers do
      include Rack::Utils
      alias_method :h, :escape_html
    end

    set :public, File.expand_path("../../../public", __FILE__)
    set :views, File.expand_path("../../../lib/bug_hunter/views", __FILE__)

    before do
    end

    get "/" do
      haml :"index"
    end

    private
    def error_not_found
      status 404
    end
  end
end
