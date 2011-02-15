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

      def pluralized_name
        name.demodulize.tableize
      end

    end

    module InstanceMethods

      def initialize(name, metadata = nil, content = nil)
        self.name = name
        self.metadata = metadata
        self.content = content
      end

      def filename
        @filename ||= "#{self.class.pluralized_name}/#{name}"
      end

      def staged_filename
        File.join Amiba::Configuration.staged_dir, filename + ".#{format}"
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

      protected

      def name=(n)
        @name = n
      end

      def metadata
        @metadata
      end

      def metadata=(meta)
        return @metadata unless @metadata.nil?

        @metadata = source_valid? ? documents.first : {}
        @metadata = @metadata.merge(meta) if meta
        @metadata = HashWithIndifferentAccess.new(@metadata)
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
      metadata_fields :layout, :format, :title, :description, :category

      VALID_FORMATS = %w{haml markdown}
      validates_presence_of :layout, :format, :title, :description, :category
      validates_inclusion_of :format, :in => VALID_FORMATS

      def output_filename
        File.join(Amiba::Configuration.site_dir, "public/#{name}.html")
      end
    end

    class Layout
      include Amiba::Source
      metadata_fields :format
    end
  end
end

require 'amiba/source/entry'
require 'amiba/source/entry_cache'
