require 'yaml'

module Amiba
  module Page


    # Simple helper class to track filenames, file contents, etc of
    # a page source file.
    class Source
      attr_reader :name
      
      def initialize(name)
        @name = name
      end

      def metadata
        documents.first
      end

      def content
        documents.last
      end

      def layout
        metadata['layout'] || 'default'
      end

      def layout_filename
        Dir.glob("layouts/#{layout}.*").first
      end

      def exists?
        !Dir.glob("pages/#{name}.*").empty?
      end

      def filename
        Dir.glob("pages/#{name}.*").first
      end

      def staged_filename
        File.join(Amiba::STAGED_DIR, filename)
      end

      def output_filename
        File.join(Amiba::SITE_DIR, name + ".html")
      end

      def dump
        YAML.dump({}.merge(metadata)) + YAML.dump(content)
      end

      private

      def documents
        @documents ||= YAML.load_stream(File.read(filename)).documents
      end
    end

    
    # Thor task to create a new page. It checks for the existance of a page already existing
    # and that the user specified a valid format before progressing.
    class Create < Thor::Group
      include Amiba::Generator

      namespace :"page:create"
      argument :name
      class_option :layout, :default => "default"
      class_option :format, :default => "haml"
      class_option :title, :required => true, :default => "Default title"
      class_option :description, :default => "Default description"
      class_option :type, :default => "plain"

      VALID_FORMATS = %w{haml markdown}

      def init_source
        @source = Source.new(name)
      end

      def should_not_exist
        if @source.exists?
          raise Thor::Error.new("Error:A page called '#{name}' has already been created.")
        end
      end

      def should_be_correct_format
        unless VALID_FORMATS.include?(options[:format])
          raise Thor::Error.new("Error: format should be one of #{VALID_FORMATS.join(', ')}")
        end
      end

      def create_page
        metadata = options.reject {|k| [:root_dir].include?(k.to_sym)}
        content = Templates.send(options[:format].to_sym)
        create_file(target_filename) do
          YAML.dump({}.merge(metadata)) + YAML.dump(content)
        end
      end

      no_tasks do
        def target_filename
          "pages/#{name}.#{options[:format]}"
        end
      end
    end

    
    # Thor task to destroy a page. It will delete all files matching the page name
    class Destroy < Thor::Group
      include Amiba::Generator

      namespace :"page:destroy"
      argument :name

      def page
        Dir.glob("pages/#{name}.*") do |fn|
          if ask("Are you sure you want to delete #{fn}? This is irreversible (y/n): ")
            remove_file(fn)
          end
        end
      end
      
    end


    # Stages and builds a page from the template in to a static file.
    class Build < Thor::Group
      include Amiba::Generator

      namespace :"page:build"
      argument :page
      
      def init_source
        @source = Source.new(page)
      end

      def stage
        create_file(@source.staged_filename) do
          @source.content
        end
      end

      def build
        layout = Tilt.new(@source.layout_filename)
        page = Tilt.new(@source.staged_filename)
        scope = Object.new

        create_file(@source.output_filename) do
          layout.render(scope) do
            page.render(scope)
          end
        end
      end

      no_tasks do
        def page_filename
          Dir.glob("pages/#{page}.*").first
        end

        def staging_page_filename
          "staging/#{page_filename}"
        end
      end
      
    end


    # Lists all pages currently managed by this Amiba project
    class List < Thor::Group
      include Amiba::Generator

      namespace :"page:list"

      def list
        Dir.glob("pages/*").each {|p| say File.basename(p)}
      end
    end


    # Hate this - will deprecate as soon as I think of a more elegant solution
    class Templates
      class << self
        def haml
          "%h1 Title\n%p Body\n"
        end

        def markdown
          "h1. Title\np. Body\n"
        end
      end
    end

  end
end
