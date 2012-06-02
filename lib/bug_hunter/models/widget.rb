module BugHunter
  class Widget
    include Mongoid::Document

    field :name
    field :title

    belongs_to :dashboard, :class_name => "BugHunter::Dashboard"
  end
end