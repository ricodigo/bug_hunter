module BugHunter
  class Error
    include Mongoid::Document
    include Mongoid::Timestamps

    field :is_rails, :type => Boolean, :default => false
    field :message, :type => String, :required => true
    field :backtrace, :type => Array, :required => true
    field :url, :type => String, :required => true
    field :params, :type => Hash, :required => true

    field :file, :type => String, :required => true
    field :line, :type => Integer, :required => true
    field :method, :type => String
    field :line_content, :type => String

    field :request_env, :type => Hash, :required => true

    field :times, :type => Integer, :default => 1

    field :action, :type => String
    field :controller, :type => String
    field :assignee, :type => String

    index :message
    index [[:message, :file, :line, :method]]

    validate :message do
      if BugHunter::Error.where(unique_error_selector).only(:_id).first
        errors.add(:uniqueness, "This error is not unique")
      end
    end

    def unique_error_selector
      msg = self[:message]
      if msg.match(/#<.+>/)
        msg = /^#{Regexp.escape($`)}/
      end

      {
        :message => msg,
        :file => self.file,
        :line => self.line,
        :method => self.method
      }
    end


    def self.build_from(env, exception)
      doc = self.new
      doc[:message] = exception.message
      doc[:backtrace] = exception.backtrace

      env = env.dup.delete_if {|k,v| k.include?(".") }
      doc[:request_env] = env

      scheme = if env['HTTP_VERSION'] =~ /^HTTPS/i
        "https://"
      else
        "http://"
      end

      url = "#{scheme}#{env["HTTP_HOST"]}#{env["REQUEST_PATH"]}"
      params = {}
      if env["QUERY_STRING"] && !env["QUERY_STRING"].empty?
        url << "?#{env["QUERY_STRING"]}"

        env["QUERY_STRING"].split("&").each do |e|
          k,v = e.split("=")
          params[k] = v
        end
      end
      doc[:url] = url
      if defined?(Rails)
        doc[:is_rails] = true
        doc[:action] = params[:action]
        doc[:controller] = params[:controller]
      end

      doc[:params] = params

      exception.backtrace.each do |line|
        if line !~ /\/usr/ && line =~ /^(.+):(\d+):in `(.+)'/ # I need better way to detect this
          doc[:file] = $1
          doc[:line] = $2.to_i
          doc[:method] = $3

          doc[:line_content] = File.open(doc[:file]).readlines[doc[:line]-1]
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
