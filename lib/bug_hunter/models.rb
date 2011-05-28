module BugHunter
  class Error
    include Mongoid::Document
    include Mongoid::Timestamps

    field :is_rails, :type => Boolean, :required => true
    field :message, :type => String, :required => true
    field :backtrace, :type => Array, :required => true
    field :url, :type => String, :required => true
    field :params, :type => Hash, :required => true
    field :file_line, :type => String, :required => true
    field :request_env, :type => Hash, :required => true

    field :error_count, :type => Integer, :default => 0

    field :action, :type => String
    field :controller, :type => String
    field :assignee, :type => String

    validates_uniqueness_of :message, :scope => [:file_line]


    def self.build_from(exception)
      doc = self.new
      doc[:message] = exception.message
      doc[:backtrace] = exception.backtrace
      exception.backtrace.each do |line|
        if line !~ /\/usr/ # I need better way to detect this
          doc[:file_line] = line
          break
        end
      end


      doc
    end
  end # Error


  class Project
    include Mongoid::Document
    include Mongoid::Timestamps

    field :name, :type => String
    field :errors_count, :type => Integer
    field :errors_resolved_count, :type => Integer
    field :members, :type => Array

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
