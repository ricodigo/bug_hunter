module BugHunter
  class DashboardApp < Sinatra::Base
    include BugHunter::UiHelper
    include BugHunter::RoutesHelper

    set :haml, :layout => :'dashboard/layout'

    get '/dashboard' do
      haml :'dashboard/index'
    end
  end
end
