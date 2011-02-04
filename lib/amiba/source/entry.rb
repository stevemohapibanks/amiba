module Amiba
  module Source
    class Entry
      include Amiba::Source
      attr_accessor :category
      metadata_fields :format, :title, :description

      validates_presence_of :format, :title

      class << self
        def all
          all_entry_pairs.map { |cat, name| Amiba::Source::Entry.new(cat, name) }
        end

        protected

        def all_entry_pairs
          all_entry_files.map do |name|
            name =~ /.*\/(.*)\/(.*)/ ? [$1.singularize.to_sym, $2] : nil
          end.compact
        end
        
        def all_entry_files
          Dir.glob('entries/*/*')
        end
      end

      def initialize(category, name, metadata = nil, content = nil)
        self.category = category
        self.name = name
        self.metadata = metadata
        self.content = content
      end

      def filename
        File.join("entries", category.to_s.downcase.pluralize, name)
      end
      
      def staged_filename
        File.join(Amiba::Configuration.staged_dir, filename + ".#{format.to_s}")
      end

      def output_filename
        File.join(Amiba::Configuration.site_dir, 'public', category.to_s.downcase.pluralize, "#{name}.html")
      end
    end
  end
end
