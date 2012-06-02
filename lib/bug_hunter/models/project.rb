module BugHunter
  class Project
    include Mongoid::Document
    include Mongoid::Timestamps

    field :name, :type => String
    field :errors_count, :type => Integer, :default => 0
    field :errors_resolved_count, :type => Integer, :default => 0
    field :members, :type => Array, :default => []

    validate :on => :create do
      errors.add(:singleton, "You can't create for than one instance of this model") if BugHunter::Project.first.present?
    end

    def self.instance
      if project = BugHunter::Project.first
        project
      else
        BugHunter::Project.create
      end
    end

    protected
  end
end