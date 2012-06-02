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

      table.update_attributes(opts) if !opts.empty?

      table
    end

    def push_table(name, *row)
      BugHunter::TableWidget.collection.update({:name => name}, {:$push => {:data => row}}, {:multi => true})
    end

    def create_list(name, opts)
      list = self.widgets.where(:name => name, :_type => "BugHunter::ListWidget").first
      if list.nil?
        list = BugHunter::ListWidget.new(:name => name, :dashboard => self)
        self.widgets << list
      end

      list.update_attributes(opts) if !opts.empty?

      list
    end

    def push_list(name, row)
      BugHunter::ListWidget.collection.update({:name => name}, {:$push => {:data => row}}, {:multi => true})
    end

    def create_counter(name, opts)
      counter = self.widgets.where(:name => name, :_type => "BugHunter::CounterWidget").first
      if counter.nil?
        counter = BugHunter::CounterWidget.new(:name => name, :dashboard => self)
        self.widgets << counter
      end

      counter.update_attributes(opts) if !opts.empty?

      counter
    end

    def increment_counter(name, value)
      BugHunter::CounterWidget.collection.update({:name => name}, {:$inc => {:value => value}}, {:multi => true})
    end

    def set_counter(name, value)
      BugHunter::CounterWidget.collection.update({:name => name}, {:$set => {:value => value}}, {:multi => true})
    end
  end
end
