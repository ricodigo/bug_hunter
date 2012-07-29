module BugHunter
  class ExceptionsWidget < BugHunter::Widget

    field :exception_type, :type => String
    field :exclude, :type => Array, :default => []
    field :rows, :type => Integer, :default => 15

    def find_data
      query = {}
      if self.exception_type
        query[:exception_type] = self.exception_type
      end
      query[:exception_type.nin] = self.exclude

      BugHunter::Error.where(query).order_by(:created_at.desc).limit(self.rows)
    end
  end
end
