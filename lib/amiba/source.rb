module Amiba
  module Source

    def self.included(base)
      base.send :include, InstanceMethods
      base.send :extend, ClassMethods
      base.send :attr_reader, :name
      base.send :include, ActiveModel::Validations
    end

    module ClassMethods

      def metadata_fields(*names)
        names.each do |name|
          define_metadata_accessor(name)
        end
      end

      def pluralized_name
        name.demodulize.tableize
      end

      def define_metadata_accessor(name)
        module_eval <<-STR
            def #{name}
              metadata[:#{name.to_s}]
            end

            def #{name}=(val)
              metadata[:#{name.to_s}] = val
            end
        STR
      end

    end

    module InstanceMethods
      include Amiba::Repo

      attr_accessor :format

      def initialize(name, format='haml', metadata = nil, content = nil)
        ext = File.extname name
        fn = File.basename(name, ext)
        dn = File.dirname name
        f = dn == "." ? fn : File.join(dn, fn)

        self.name = f
        self.format = format
        self.metadata = metadata
        self.content = content
      end

      def filename
        @filename ||= File.join(self.class.pluralized_name, "#{name}.#{format}")
      end

      def staged_filename
        File.join Amiba::Configuration.staged_dir, filename
      end

      def new?
        !File.exist?(filename)
      end

      def metadata_and_content
        YAML.dump(metadata.to_hash) + YAML.dump(content)
      end

      def save(&block)
        return false unless valid?
        yield filename, metadata_and_content
        true
      end

      def content
        @content
      end

      def metadata
        @metadata ||= source_valid? ? documents.first : {}
      end

      def pubdate
        @metadata["pubdate"] ||= last_commit_date filename
      end

      protected

      def method_missing(method_sym, *args, &block)
        md = method_sym.to_s.gsub(/=$/,'')
        if !metadata[md.to_s].nil?
          self.class.define_metadata_accessor(md)
          send(method_sym, *args, &block)
        else
          super
        end
      end

      def name=(n)
        @name = n
      end

      def metadata=(meta)
        m = meta ? metadata.merge(meta) : metadata
        @metadata = HashWithIndifferentAccess.new(m)
      end

      def content=(c)
        return @content unless @content.nil?
        @content = self.new? ? c : documents.last
      end

      def documents
        @documents ||= YAML.load_stream(File.read(filename)).documents
      rescue
        nil
      end

      def source_valid?
        documents.first && documents.last
      rescue
        false
      end

    end

    class Page
      include Amiba::Source
      metadata_fields :layout, :title, :description, :category, :state

      VALID_FORMATS = %w{haml markdown}
      validates_presence_of :layout, :title, :description, :category, :state

      def output_filename
        File.join(Amiba::Configuration.site_dir, "public/#{name}.html")
      end
    end

    class Layout
      include Amiba::Source

      def content=(c)
        @content ||= self.new? ? c : File.read(filename)
      end
    end
  end
end
