module BugHunter
  class App < Sinatra::Base
    include BugHunter::UiHelper
    include BugHunter::RoutesHelper

    if BugHunter.config["enable_auth"]
      use Rack::Auth::Basic, "Restricted Area" do |username, password|
        [username, password] == [BugHunter.config["username"], BugHunter.config["password"]]
      end
    end

    def initialize(*args)
      BugHunter.connect
      super(*args)
    end

#     use BugHunter::Middleware

    helpers do
      include Rack::Utils
      alias_method :h, :escape_html
    end

    dir = File.dirname(File.expand_path(__FILE__))
    set :views,   "#{dir}/views"
    set :public_folder,  "#{dir}/public"

    before do
    end

    get "/" do
      haml :"main"
    end

    get "/errors" do
      conds = {:resolved => false}
      if params[:resolved] == "1"
        conds[:resolved] = true
      end

      if params[:unassigned] == "1"
        conds[:assignee] = nil
      elsif params[:assignee]
        conds[:assignee] = params[:assignee]
      end

      if params[:exception]
        conds[:exception_type] = params[:exception]
      end

      if params[:last_update_at]
        conds[:updated_at] = {:$gt => Time.new(params[:last_update_at].to_i)}
      end
      @errors = BugHunter::Error.without(:comments,:backtrace).where(conds).desc(:updated_at)
      @errors.to_json
    end

    get "/group" do
      results = []
      case params[:name]
        when "by_exception"
          pipeline = [
            {
              :$group => {
                          :_id => "$exception_type",
                          :count => {:$sum => 1}
                         }
            },
            :$sort => {:count => -1}
          ]
          results = BugHunter::Error.collection.aggregate(pipeline)
      end
      results.to_json
    end

    get "/errors/:id" do
      @error = BugHunter::Error.find(params[:id])
      @error.to_json
    end

    post "/errors/:id/comment" do
      @error = BugHunter::Error.minimal.find(params[:id])
      @error.add_comment(params[:from], params[:message], request.ip)

      redirect error_path(@error)
    end

    get "/errors/:id/resolve" do
      @error = BugHunter::Error.minimal.find(params[:id])
      @error.resolve!

      if params[:include_similar] == "1"
        @error.similar_errors.each do |err|
          err.resolve!
        end
      end

      redirect error_path(@error)
    end

    get "/errors/:id/reopen" do
      @error = BugHunter::Error.minimal.find(params[:id])
      @error.unresolve!

      redirect error_path(@error)
    end

    get "/errors/:id/assign" do
      @error = BugHunter::Error.minimal.find(params[:id])

      haml :"errors/assign"
    end

    get "/errors/:id/assign_to" do
      @error = BugHunter::Error.minimal.find(params[:id])

      @error.assignee = params[:member]
      @error.save(:validate => false)

      redirect error_path(@error)
    end

    post "/add_member" do
      project = Project.instance
      member = params[:name]
      project.members << member if member && !member.empty?

      if project.save
        if params[:assign_to]
          @error = BugHunter::Error.minimal.find(params[:assign_to])
          @error.assignee = member
          @error.save(:validate => false)
        end
      end

      if @error
        redirect error_path(@error)
      else
        redirect "/"
      end
    end

    private
    def error_not_found
      status 404
    end
  end
end
