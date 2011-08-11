require 'amiba/source'

module Amiba
  module Source
    class Entry
      extend Amiba::Source::EntryFinder
      include Amiba::Source
      
      ActiveSupport::Inflector.inflections do |inflect|
        inflect.uncountable "blog"
      end

      attr_accessor :category
      metadata_fields :title, :slug, :state, :layout

      validates_presence_of :title, :state, :layout

      def initialize(category, name, format, metadata = nil, content = nil)
        self.category = category
        self.name = name
        self.format = format
        self.metadata = metadata
        self.metadata["layout"] ||= category.to_s
        self.content = content
      end

      def filename
        File.join("entries", category.to_s.downcase.pluralize, name + ".#{format.to_s}")
      end
      
      alias_method :staged_filename, :filename

      def output_filename
        File.join(Amiba::Configuration.site_dir, 'public', category.to_s.downcase.pluralize, "#{name}.html")
      end

      def link
        URI.escape( ["", category.to_s.downcase.pluralize, "#{name}.html"].join("/") )
      end

      def render
        Amiba::Tilt.new(self).render(Amiba::Scope.new(self))
      end

      def ref
        "#{category.to_s.downcase.pluralize}_#{name}"
      end
    end
  end
end
