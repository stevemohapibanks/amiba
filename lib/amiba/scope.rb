module Amiba
  class Scope

    attr_reader :page
    
    def initialize(page)
      @page = page
    end

    def title
      page.title
    end

    def description
      page.description
    end

    def content
      page_renderer.render(self)
    end

    def entries(category=nil, count=nil)
      entries = Amiba::Source::Entry.all(category: category)
      if count
        return entries[0..count-1]
      else
        return entries
      end
    end

    protected

    def page_renderer
      Tilt.new page.staged_filename
    end
  end
end
