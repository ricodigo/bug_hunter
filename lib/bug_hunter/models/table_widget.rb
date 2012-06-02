module BugHunter
  class TableWidget < BugHunter::Widget
    field :rows, :type => Integer, :default => 10
    field :header, :type => Array, :default => []

    field :data, :type => Array, :default => []

    def find_data
      data = BugHunter::TableWidget.collection.find(
        {:_type =>"BugHunter::TableWidget", :_id => self.id},
        {:fields => {:data => {:$slice => -self.rows}}}
      ).next_document['data']

      self.data = data
      self.save

      data
    end
  end
end