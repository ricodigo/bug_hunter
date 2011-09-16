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
              [content, content_tag(:span, :class => "ui-li-count") { date_format(extra) }].join
            end
          end
        end.join
      end
    end

    def date_format(date)
      now = Time.now
      if date.today?
        date.strftime("%I:%M %p")
      elsif now.yesterday.beginning_of_day < date && date < now.yesterday.end_of_day
        "yesterday #{date.strftime("%I:%M %p")}"
      else
        date.strftime("%b %d, %Y")
      end
    end

    private
    def sections
      @sections ||= Hash.new {|k,v| k[v] = [] }
    end
  end
end

