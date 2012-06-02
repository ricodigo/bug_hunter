module BugHunter
  class Dashboard
    include Mongoid::Document
    include Mongoid::Timestamps

    field :name, :type => String
    index :name

    has_many :widgets, :class_name => "BugHunter::Widget"

    def create_table(name, opts)
      table = self.widgets.where(:name => name, :_type => "BugHunter::TableWidget").first
      if table.nil?
        table = BugHunter::TableWidget.new(:name => name, :dashboard => self)
        self.widgets << table
      end

      table.update_attributes(opts)

      table
    end

    def create_list(name, opts)
      list = self.widgets.where(:name => name, :_type => "BugHunter::ListWidget").first
      if list.nil?
        list = BugHunter::ListWidget.new(:name => name, :dashboard => self)
        self.widgets << list
      end

      list.update_attributes(opts)

      list
    end

    def create_counter(name, args)
      counter = self.widgets.where(:name => name, :_type => "BugHunter::CounterWidget").first
      if counter.nil?
        counter = BugHunter::TableWidget.new(:name => name, :dashboard => self)
        self.widgets << counter
      end

      counter.update_attributes(opts)

      counter
    end
  end
end
