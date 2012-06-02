$:.unshift File.expand_path("../lib", __FILE__)
require 'bug_hunter'


BugHunter.connect
dashboard = BugHunter.create_dashboard("stats 1")
dashboard.create_table("Table 1", :rows => 30, :header => ["id", "data1"])

run BugHunter.app

