module Amiba
  module Source
    class Entry
      extend Amiba::Source::EntryFinder
      include Amiba::Source
      
      attr_accessor :category
      metadata_fields :title, :slug, :state

      validates_presence_of :title, :state

      def initialize(category, name, format, metadata = nil, content = nil)
        self.category = category
        self.name = name
        self.format = format
        self.metadata = metadata
        self.content = content
      end

      def filename
        File.join("entries", category.to_s.downcase.pluralize, name + ".#{format.to_s}")
      end
      
      def staged_filename
        File.join(Amiba::Configuration.staged_dir, filename)
      end

      def output_filename
        File.join(Amiba::Configuration.site_dir, 'public', category.to_s.downcase.pluralize, "#{name}.html")
      end
    end
  end
end
