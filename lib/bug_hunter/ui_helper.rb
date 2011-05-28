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
    def list_view(list = [], &_block)
      content_tag(:ul, :"data-role"=>"listview", :"data-filter"=>"true") do
        list.map do |e|
          content_tag :li do
            url, content, extra = _block.call(e)

            content_tag(:a, :href => url) do
              content
            end
          end
        end.join
      end
    end

    private
    def sections
      @sections ||= Hash.new {|k,v| k[v] = [] }
    end
  end
end

