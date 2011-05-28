module BugHunter
  class App < Sinatra::Base
    include BugHunter::UiHelper
    include BugHunter::RoutesHelper

    def initialize(*args)
      BugHunter.connect
      super(*args)
    end

    use BugHunter::Middleware

    helpers do
      include Rack::Utils
      alias_method :h, :escape_html
    end

    set :public, File.expand_path("../../../public", __FILE__)
    set :views, File.expand_path("../../../lib/bug_hunter/views", __FILE__)

    before do
    end

    get "/" do
      @errors = BugHunter::Error.paginate(:per_page => params[:per_page]||10, :page => params[:page])

      haml :"index"
    end

    get "/errors/:id" do
      @error = BugHunter::Error.find(params[:id])

      haml :"errors/show"
    end

    private
    def error_not_found
      status 404
    end
  end
end
