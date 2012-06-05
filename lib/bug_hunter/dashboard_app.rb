module BugHunter
  class DashboardApp < Sinatra::Base
    include BugHunter::UiHelper
    include BugHunter::RoutesHelper

    set :haml, :layout => :'dashboard/layout'

    helpers do
      include Rack::Utils
      alias_method :h, :escape_html
    end

    get '/dashboard/track.js' do
      haml :'dashboard/track.js', :layout => false
    end

    get '/dashboard' do
      haml :'dashboard/index'
    end

    get '/dashboard/:id' do
      @dashboard = BugHunter::Dashboard.find(params[:id])
      haml :'dashboard/show'
    end

    post '/dashboard/js_error' do
      if params['message'] && params['file'] && params['row']
        BugHunter.push_js_error(params['message'], params['file'], params['row'], request.user_agent)
      end

      200
    end
  end
end
