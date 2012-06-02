module BugHunter
  class ListWidget < BugHunter::Widget
    field :rows, :type => Integer, :default => 10

    field :data, :type => Array, :default => []
  end
end

