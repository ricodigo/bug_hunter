require 'rubygems'
require 'bundler/setup'

$:.unshift File.expand_path("..", __FILE__)

Bundler.require

require 'json'

require 'benchmark'
require 'sinatra'
require 'haml'
require 'sass'
require 'mongoid'

require 'net/http'
require 'uri'
require 'cgi'
require 'benchmark'
require 'pry'

require 'bug_hunter/config'
require 'bug_hunter/middleware'
require 'bug_hunter/ui_helper'
require 'bug_hunter/routes_helper'

require 'bug_hunter/models/error'
require 'bug_hunter/models/project'
require 'bug_hunter/models/dashboard'

require 'bug_hunter/models/widget'
require 'bug_hunter/models/table_widget'
require 'bug_hunter/models/list_widget'
require 'bug_hunter/models/counter_widget'
require 'bug_hunter/models/exceptions_widget'
require 'bug_hunter/models/data_point_widget'

require 'bug_hunter/slow_request_error'
require 'bug_hunter/dashboard_app'
require 'bug_hunter/app'
require 'bug_hunter/railtie' if defined?(Rails) && Rails::VERSION::MAJOR >= 3

module BugHunter
  def self.app
    BugHunter::App
  end

  def self.create_dashboard(name)
    BugHunter::Dashboard.where(:name => name).first || BugHunter::Dashboard.create(:name => name)
  end

  def self.push_js_error(message, file, row, user_agent)
    BugHunter::TableWidget.add_row("JsErrors", Time.now.strftime("%b %e, %l:%M %p"), message, file, row, user_agent)
  end

  def self.push_point(name, value)
    BugHunter::DataPointWidget.add_point(name, value)
  end

  def self.push_table(name, *row)
    BugHunter::TableWidget.add_row(name, *row)
  end

  def self.push_list(name, row)
    BugHunter::ListWidget.add_row(name, row)
  end

  def self.increment_counter(name, value)
    BugHunter::CounterWidget.collection.find({:name => name}).update_all({:$inc => {:value => value}})
  end

  def self.set_counter(name, value)
    BugHunter::CounterWidget.collection.find({:name => name}).update_all({:$set => {:value => value}})
  end

  def self.connect
    begin
      return if !Mongoid.sessions.empty? || Mongoid.session(:default)
    rescue Mongoid::Errors::InvalidDatabase, Mongoid::Errors::NoSessionConfig, TypeError
      # let it pass to configure the database
    end

    ENV["RACK_ENV"] ||= ENV["RAILS_ENV"] || 'development'
    if !ENV["RACK_ENV"]
      raise ArgumentError, "please define the env var RACK_ENV"
    end

    if File.exist?("/etc/mongoid.yml")
      Mongoid.load("/etc/mongoid.yml", ENV['RACK_ENV'])
    elsif File.exist?("config/mongoid.yml")
      Mongoid.load!("config/mongoid.yml", ENV['RACK_ENV'])
    elsif File.exist?("mongoid.yml")
      Mongoid.load!("mongoid.yml", ENV['RACK_ENV'])
    else
      raise ArgumentError, "/etc/mongoid.yml, ./config/mongoid.yml or ./mongoid.yml were not found"
    end
  end
end

