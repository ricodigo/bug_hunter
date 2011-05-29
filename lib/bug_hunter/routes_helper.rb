module BugHunter
  module RoutesHelper
    def error_path(error)
      "#{ENV["BUGHUNTER_PATH"]}/errors/#{error.id}"
    end

    def root_path
      "#{ENV["BUGHUNTER_PATH"]}/"
    end
  end
end

