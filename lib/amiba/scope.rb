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

    def entries
      Amiba::Source::Entry
    end

    def partial(path, locals={})
      p = Amiba::Source::Partial.new path
      Tilt.new(p.filename).render(Amiba::Scope.new(p), locals)
    end

    protected

    def page_renderer
      Tilt.new page.staged_filename
    end
  end
end
