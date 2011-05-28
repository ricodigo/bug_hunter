module BugHunter
  module RoutesHelper
    def error_path(error)
      "#{ENV["BUGHUNTER_PATH"]}/errors/#{error.id}"
    end
  end
end

