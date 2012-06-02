module BugHunter
  class ListWidget < BugHunter::Widget
    field :rows, :type => Integer, :default => 10

    field :data, :type => Array, :default => []

    def self.add_row(name, row)
      self.collection.update({:name => name}, {:$push => {:data => row}}, {:multi => true})
    end

    def find_data
      data = BugHunter::ListWidget.collection.find(
        {:_type =>"BugHunter::ListWidget", :_id => self.id},
        {:fields => {:data => {:$slice => -self.rows}}}
      ).next_document['data']

      self.data = data
      self.save

      data
    end
  end
end

