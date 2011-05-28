require 'rubygems'

$:.unshift File.expand_path("..", __FILE__)

require 'json'

require 'benchmark'
require 'sinatra'
require 'haml'
require 'sass'
require 'mongo'
require 'bson'
require 'mongoid'

require 'net/http'
require 'uri'
require 'cgi'

require 'bug_hunter/middleware'
require 'bug_hunter/ui_helper'
require 'bug_hunter/routes_helper'
require 'bug_hunter/models'
require 'bug_hunter/app'

module BugHunter
  def self.app
    BugHunter::App
  end

  def self.connect
    return unless Mongoid.config.databases.empty?

    ENV["RACK_ENV"] ||= ENV["RAILS_ENV"]
    if !ENV["RACK_ENV"]
      raise ArgumentError, "please define the env var RACK_ENV"
    end

    if File.exist?("/etc/mongoid.yml")
      Mongoid.load("/etc/mongoid.yml")
    elsif File.exist?("config/mongoid.yml")
      Mongoid.load!("config/mongoid.yml")
    elsif File.exist?("mongoid.yml")
      Mongoid.load!("mongoid.yml")
    else
      raise ArgumentError, "/etc/mongoid.yml, ./config/mongoid.yml or ./mongoid.yml were not found"
    end
  end
end

