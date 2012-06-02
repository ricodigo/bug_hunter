module BugHunter
  class Dashboard
    include Mongoid::Document
    include Mongoid::Timestamps

    field :name, :type => String
    index :name

    has_many :widgets, :class_name => "BugHunter::Widget"

    def create_exceptions_widget(name, opts)
      exceptions = self.widgets.where(:name => name, :_type => "BugHunter::ExceptionsWidget").without(:data).first
      if exceptions.nil?
        exceptions = BugHunter::ExceptionsWidget.new(:name => name, :dashboard => self)
        self.widgets << exceptions
      end

      exceptions.update_attributes!(opts) if !opts.empty?

      exceptions
    end

    def create_line_chart(name, opts)
      create_data_point_chart(name, opts.merge(:display_as => 'line'))
    end

    def create_grid_chart(name, opts)
      create_data_point_chart(name, opts.merge(:display_as => 'grid'))
    end

    def create_bar_chart(name, opts)
      create_data_point_chart(name, opts.merge(:display_as => 'bar'))
    end

    def create_pie_chart(name, opts)
      create_data_point_chart(name, opts.merge(:display_as => 'pie'))
    end

    def create_data_point_chart(name, opts)
      widget = self.widgets.where(:name => name, :_type => "BugHunter::DataPointWidget").without(:data).first
      if widget.nil?
        widget = BugHunter::DataPointWidget.new(:name => name, :dashboard => self)
        self.widgets << widget
      end

      widget.update_attributes!(opts) if !opts.empty?

      widget
    end

    def create_table(name, opts)
      table = self.widgets.where(:name => name, :_type => "BugHunter::TableWidget").without(:data).first
      if table.nil?
        table = BugHunter::TableWidget.new(:name => name, :dashboard => self)
        self.widgets << table
      end

      table.update_attributes!(opts) if !opts.empty?

      table
    end

    def create_list(name, opts)
      list = self.widgets.where(:name => name, :_type => "BugHunter::ListWidget").without(:data).first
      if list.nil?
        list = BugHunter::ListWidget.new(:name => name, :dashboard => self)
        self.widgets << list
      end

      list.update_attributes!(opts) if !opts.empty?

      list
    end

    def create_counter(name, opts)
      counter = self.widgets.where(:name => name, :_type => "BugHunter::CounterWidget").without(:data).first
      if counter.nil?
        counter = BugHunter::CounterWidget.new(:name => name, :dashboard => self)
        self.widgets << counter
      end

      counter.update_attributes!(opts) if !opts.empty?

      counter
    end
  end
end
