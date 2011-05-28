require 'rubygems'

require 'json'

require 'benchmark'
require 'sinatra'
require 'haml'
require 'sass'
require 'mongo'
require 'bson'

require 'net/http'
require 'uri'
require 'cgi'

require 'bug_hunter/ui_helper'
require 'bug_hunter/routes_helper'
require 'bug_hunter/models'
require 'bug_hunter/app'

module BugHunter
  def self.app
    BugHunter::App
  end
end

