$:.unshift File.expand_path("../lib", __FILE__)
require 'bug_hunter'


BugHunter.connect
dashboard = BugHunter.create_dashboard("stats 1")

run BugHunter.app

