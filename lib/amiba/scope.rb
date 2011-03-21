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

    def site_name
       Amiba::Configuration.site_name.nil? ? "" : Amiba::Configuration.site_name
    end

    def site_url
      Amiba::Configuration.site_name.nil? ? "" : "http://#{Amiba::Configuration.site_name}/"
    end

    def full_url(frag)
      if site_url.empty?
        frag
      else
        URI.join(site_url, frag).to_s
      end
    end

    protected

    def page_renderer
      Tilt.new page.staged_filename
    end
  end
end
