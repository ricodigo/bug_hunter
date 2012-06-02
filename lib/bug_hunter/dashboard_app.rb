module BugHunter
  class DashboardApp < Sinatra::Base
    include BugHunter::UiHelper
    include BugHunter::RoutesHelper

    set :haml, :layout => :'dashboard/layout'

    get '/dashboard' do
      haml :'dashboard/index'
    end

    get '/dashboard/:id' do
      @dashboard = BugHunter::Dashboard.find(params[:id])
      haml :'dashboard/show'
    end
  end
end
