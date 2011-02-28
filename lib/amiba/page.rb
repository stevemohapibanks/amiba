require 'amiba/source'

module Amiba
  module Page

    # Thor task to create a new page. It checks for the existance of a page already existing
    # and that the user specified a valid format before progressing.
    class Create < Thor::Group
      include Amiba::Generator
      include Amiba::Repo

      namespace :"page:create"
      argument :name
      argument :format, default: "haml"
      class_option :layout, default: "default"
      class_option :title, required: true
      class_option :description, required: true
      class_option :category, default: "plain"
      class_option :state, default: "draft"

      def init_source
        @source = Amiba::Source::Page.new(name, format, options, Templates.send(format.to_sym))
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
        @source.save do |filename, file_data|
          create_file filename, file_data
        end
      end

      def add_to_git
        add_and_commit @source.filename
      end

    end

    # Thor task to mark a page published.
    class Publish < Thor::Group
      include Amiba::Generator
      include Amiba::Repo

      namespace :"page:publish"
      argument :name
      argument :format, default: 'haml'

      def init_source
        @source = Amiba::Source::Page.new(name, format)
      end

      def should_exist
        if @source.new?
          raise Thor::Error.new("Error: Can't publish a page that doesn't exist.")
        end
      end

      def should_not_be_published
        if @source.state == "published"
          raise Thor::Error.new("Page already published")
        end
      end

      def save_page
        @source.state = "published"
        @source.save do |filename, file_data|
          remove_file filename, :verbose => false
          create_file(filename, :verbose => false) do
            file_data
          end
          say_status :published, filename, :green
        end
      end

      def add_to_git
        add_and_commit @source.filename, "Published #{@source.filename}"
      end

    end

    # Thor task to destroy a page. It will delete all files matching the page name
    class Destroy < Thor::Group
      include Amiba::Generator

      namespace :"page:destroy"
      argument :name
      argument :format, default: 'haml'

      def init_source
        @source = Amiba::Source::Page.new(name, format)
      end

      def page
        if ask("Are you sure you want to delete #{@source.filename}?" +
               " This is irreversible (y/n): ")
          remove_file(@source.filename)
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
          "# Title #\nBody\n"
        end
      end
    end

  end
end
