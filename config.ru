$:.unshift File.expand_path("../lib", __FILE__)
require 'bug_hunter'

# for testing purposes
# BugHunter.connect
#
# dashboard = BugHunter.create_dashboard("stats 1")
# dashboard.create_table("Table 1", :rows => 10, :header => ["id", "data1"], :title => "My Table")
# dashboard.create_list("List 1", :title => "My List")
# dashboard.create_counter("Counter 1", :title => "My Counter")
#
# 10.times do
#   dashboard.push_table("Table 1", rand(100), rand(100))
#   dashboard.push_list("List 1", rand(100))
#   dashboard.increment_counter("Counter 1", rand(100))
# end

run BugHunter.app

