require 'yaml'
require 'amiba/source'

module Amiba
  module Page

    # Thor task to create a new page. It checks for the existance of a page already existing
    # and that the user specified a valid format before progressing.
    class Create < Thor::Group
      include Amiba::Generator

      namespace :"page:create"
      argument :name
      class_option :layout, :default => "default"
      class_option :format, :default => "haml"
      class_option :title, :required => true
      class_option :description, :required => true
      class_option :category, :default => "plain"

      def init_source
        @source = Amiba::Source::Page.new(name, options, Templates.send(options[:format].to_sym))
      end

      def should_not_exist
        unless @source.new?
          raise Thor::Error.new("Error:A page called '#{name}' has already been created.")
        end
      end

      def should_be_correct_format
        if !@source.valid? && !@source.errors[:format].nil?
          raise Thor::Error.new("Error: format should be one of " +
                                Amiba::Source::Page::VALID_FORMATS.join(','))
        end
      end

      def save_page
        @source.save do |source_filename, file_data|
          create_file source_filename, file_data
        end
      end
    end

    
    # Thor task to destroy a page. It will delete all files matching the page name
    class Destroy < Thor::Group
      include Amiba::Generator

      namespace :"page:destroy"
      argument :name

      def init_source
        @source = Amiba::Source::Page.new(name)
      end

      def page
        if ask("Are you sure you want to delete #{@source.source_filename}?" +
               " This is irreversible (y/n): ")
          remove_file(@source.source_filename)
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
