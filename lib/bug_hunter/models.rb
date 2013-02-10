module BugHunter
  extend ActiveSupport::Concern
  class Error
    include Mongoid::Document
    include Mongoid::Timestamps

    field :is_rails, :type => Boolean, :default => false
    field :exception_type, :type => String
    field :message, :type => String
    field :backtrace, :type => Array
    field :url, :type => String
    field :absolute_url, :type => String
    field :params, :type => Hash

    field :file, :type => String
    field :line, :type => Integer
    field :method, :type => String
    field :line_content, :type => String

    field :request_env, :type => Hash, :default => {}

    field :times, :type => Integer, :default => 1

    field :action, :type => String
    field :controller, :type => String
    field :assignee, :type => String

    field :resolved, :type => Boolean, :default => false

    field :comments, :type => Array, :default => []
    field :comments_count

    index(message: 1)
    index({
      message: 1,
      file: 1,
      line: 1,
      method: 1,
      updated_at: 1
    }, {})

    index({
      exception_type: 1,
      updated_at: 1,
      resolved: 1
    }, {})

    validates_presence_of :message
    validates_presence_of :backtrace, :allow_blank => true
    validates_presence_of :url
    validates_presence_of :params, :allow_blank => true
    validates_presence_of :file, :allow_blank => true
    validates_presence_of :line, :allow_blank => true
    validates_presence_of :request_env

    after_create :update_project

    validate :message do
      if BugHunter::Error.where(unique_error_selector).only(:_id).first
        errors.add(:uniqueness, "This error is not unique")
      end
    end

    def self.minimal
      without(:comments, :request_env, :backtrace)
    end

    def similar_errors
      self.class.where(:message => partial_message(true),
                       :_id.ne => self.id)
    end

    def add_comment(from, message, ip)
      comment = {:from => from,
                 :message => message,
                 :created_at => Time.now.utc,
                 :ip => ip}

      self.collection.find({:_id => self.id}).update(
                             {:$push => {:comments => comment},
                              :$inc => {:comments_count => 1}},
                             {:multi => true})
    end

    def resolve!
      self.collection.find({:_id => self.id}).update(
                             {:$set => {:resolved => true, :updated_at => Time.now.utc}},
                             {:multi => true})
      BugHunter::Project.collection.find({:_id => BugHunter::Project.instance.id}).
                                   update({:$inc => {:errors_resolved_count => 1}})
    end

    def unresolve!
      self.collection.find({:_id => self.id}).update(
                             {:$set => {:resolved => false, :updated_at => Time.now.utc}},
                             {:multi => true})
      BugHunter::Project.collection.find({:_id => BugHunter::Project.instance.id}).
                                   update({:$inc => {:errors_resolved_count => -1}})
    end

    def unique_error_selector
      case self.exception_type
      when "BugHunter::SlowRequestError"
        {
          :resolved => false,
          :url => self.url
        }
      else
        {
          :resolved => false,
          :message => partial_message,
          :file => self.file,
          :line => self.line
        }
      end
    end

    def partial_message(regex = true)
      msg = self[:message]

      if msg.match(/#<.+>/) && $`.length > 10
        msg = $`
      elsif msg.match(/\{.+\}/) && $`.length > 10
        msg = $`
      end

      if regex
        if msg =~ /`.+'/
          r = "#{Regexp.escape($`)}`.+'"
          if $'
            r << Regexp.escape($')
          end
          msg = /^#{r}/
        elsif msg =~ /'.+'/
          r = "#{Regexp.escape($`)}'.+'"
          if $'
            r << Regexp.escape($')
          end
          msg = /^#{r}/
        else
          msg = /^#{Regexp.escape(msg)}/
        end
      end

      msg
    end

    def self.build_from(env, exception)
      doc = self.new
      doc[:message] = exception.message
      doc[:backtrace] = exception.backtrace||[]
      doc[:exception_type] = exception.class.to_s

      new_env = {}
      env.each do |k,v|
        next if k =~ /^action_/

        new_env[k.gsub(".", "_")] = v.inspect
      end
      doc[:request_env] = new_env

      scheme = if env['HTTP_VERSION'] =~ /^HTTPS/i
        "https://"
      else
        "http://"
      end

      url = "#{scheme}#{env["HTTP_HOST"]}#{env["REQUEST_PATH"]}"
      doc[:absolute_url] = url
      params = {}
      if !env["QUERY_STRING"].blank?
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

      (exception.backtrace||[]).each do |line|
        if self.highlight_line?(line) && line =~ /^(.+):(\d+):in `(.+)'/
          next if !File.exist?($1)

          doc[:file] = $1
          doc[:line] = $2.to_i
          doc[:method] = $3

          doc[:line_content] = File.open(doc[:file]).readlines[doc[:line]-1]

          break
        end
      end


      doc
    end

    def update_project
      BugHunter::Project.collection.find({:_id => BugHunter::Project.instance.id}).
                                        update({:$inc => {:errors_count => 1}})
    end

    def self.highlight_line?(line)
      line !~ /\/(usr|vendor|bundle)\//
    end
  end # Error


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
