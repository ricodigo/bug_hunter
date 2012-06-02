module BugHunter
  class CounterWidget < BugHunter::Widget
    field :value, :type => Integer, :default => 0
    field :label, :type => String
  end
end
