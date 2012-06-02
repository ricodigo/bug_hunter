module BugHunter
  class DataPointWidget < BugHunter::Widget
    DISPLAY_TYPES = %w[grid pie bar line]
    PERIOD_TYPES = %w[hourly daily weekly monthly yearly]

    field :display_as, :type => String, :default => "grid"
    field :period, :type => String, :default => "daily"

    field :points, :default => {}

    def self.add_point(name, value)
      self.where(:name => name).only(:_id, :period).each do |widget|
        widget.add_point(value)
      end
    end

    def add_point(value)
      self.class.collection.update({:_id => self.id}, {:$inc => {:"points.#{generate_key}" => value}}, {:multi => true})
    end

    def find_data
      self.points.sort_by {|k,v| k }
    end

    def format_key(key)
      parts = key.split("-")

      case parts.size
      when 1 # weekly or yearly
        if parts[0].length == 4
          "#{parts[0]}"
        else
          year = parts[0].slice!(0,4)
          first_day = Date.new(year.to_i, 1, 1)
          first_day += ((parts[0].to_i-1)*7)+1
          month = Date::MONTHNAMES[first_day.month]

          "#{month} #{first_day.day} #{first_day.year}"
        end
      when 2 # monthly
        month = Date::MONTHNAMES[parts[1].to_i]
        "#{month} #{parts[0]}"
      when 3 # daily
        month = Date::MONTHNAMES[parts[1].to_i]

        "#{month} #{parts[2]} #{parts[0]}"
      when 4 # hourly
        month = Date::MONTHNAMES[parts[1].to_i]

        "#{month} #{parts[2]} #{parts[3]}:00 #{parts[0]}"
      end
    end
    private
    def generate_key
      now = Time.now.utc
      case self.period
      when 'hourly'
        now.strftime("%Y-%m-%d-%H")
      when 'weekly'
        now.strftime("%Y%V")
      when 'monthly'
        now.strftime("%Y-%m")
      when 'yearly'
        now.strftime("%Y")
      else # daily
        now.strftime("%Y-%m-%d")
      end
    end

  end
end
