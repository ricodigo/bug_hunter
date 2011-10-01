module BugHunter
  module RoutesHelper
    def error_path(error)
      "#{request.env['SCRIPT_NAME']}/errors/#{error.id}"
    end

    def root_path
      "#{request.env['SCRIPT_NAME']}/"
    end

    def url_path(path)
      [request.env['SCRIPT_NAME'], path].join("/").squeeze('/')
    end
    alias_method :u, :url_path
  end
end

