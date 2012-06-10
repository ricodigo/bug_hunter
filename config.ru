$:.unshift File.expand_path("../lib", __FILE__)
require 'bug_hunter'

# for testing purposes
BugHunter.connect

if File.exist?("./config/boot.rb")
  require './config/boot.rb'
end

run BugHunter.app

