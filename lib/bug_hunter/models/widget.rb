module BugHunter
  class Widget
    include Mongoid::Document

    field :name
    field :title

    belongs_to :dashboard, :class_name => "BugHunter::Dashboard"

    def span
      4
    end
  end
end