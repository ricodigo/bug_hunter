module BugHunter
  class TableWidget < BugHunter::Widget
    field :rows, :type => Integer, :default => 10
    field :header, :type => Array, :default => []

    field :data, :type => Array, :default => []
  end
end
