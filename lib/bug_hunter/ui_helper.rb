module BugHunter
  module UiHelper
    def title(v)
      @title = v
    end

    def content_for(key, &block)
      sections[key] = capture_haml(&block)
    end

    def content(key)
      if section = sections[key]
        section.respond_to?(:join) ? section.join : section
      else
        ""
      end
    end

    def content_tag(name, options={}, &block)
      "<#{name} #{options.map{|k,v| "#{k}=#{v}" }.join(" ")}>#{block.call}</#{name}>"
    end

    # list_view(my_collection) {|e| [e.url, e.name, "some extra content"]}
    def list_view(list = [], options = {}, &_block)
      content_tag(:ul, :"data-role"=>"listview", :"data-filter"=>options[:filter]||false) do
        list.map do |e|
          content_tag :li do
            url, content, extra = _block.call(e)

            content_tag(:a, :href => url) do
              [content, content_tag(:span, :class => "ui-li-count") { format_date(extra) }].join
            end
          end
        end.join
      end
    end

    def format_date(date)
      if date.respond_to?(:strftime)
        now = Time.now
        if date.today?
          date.strftime("%l:%M %p")
        elsif now.yesterday.beginning_of_day < date && date < now.yesterday.end_of_day
          "yesterday #{date.strftime("%b %e, %l:%M %p")}"
        else
          date.strftime("%b %e, %l:%M %p")
        end
      else
        date
      end
    end

    def format_number(number)
      return if number.nil?

      if number < 1000
        number.to_s
      elsif number >= 1000 && number < 1000000
        "%.01fK" % (number/1000.0)
      elsif number >= 1000000
        "%.01fM" % (number/1000000.0)
      end
    end

    def format_widget_column(value)
      formatted = if value.respond_to?(:strftime)
        h(format_date(value))
      elsif value.kind_of?(Hash)
        h(value.to_json)
      elsif value.kind_of?(Array)
        h(value.inspect)
      elsif value.kind_of?(String)
        if value.length > 100
          %@<span title="#{h(value)}">#{h(value[0,100])}</span>@
        else
          h(value)
        end
      elsif value.kind_of?(Integer)
        format_number(value)
      else
        h(value.inspect)
      end

      formatted
    end

    private
    def sections
      @sections ||= Hash.new {|k,v| k[v] = [] }
    end
  end
end

