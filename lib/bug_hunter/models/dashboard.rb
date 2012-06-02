module BugHunter
  class Dashboard
    include Mongoid::Document
    include Mongoid::Timestamps

    field :name, :type => String


    index :name
  end
end
