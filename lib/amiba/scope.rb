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

    def entries(options = {})
      entries = Amiba::Source::Entry.all(options)
    end

    protected

    def page_renderer
      Tilt.new page.staged_filename
    end
  end
end
