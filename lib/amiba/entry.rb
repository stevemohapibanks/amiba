module Amiba
  module Entry

    class Create < Thor::Group
      include Amiba::Generator
      include Amiba::Repo

      namespace :"entry:create"
      argument :format, default: 'markdown'
      class_option :category, required: true
      class_option :title, required: true
      class_option :state, default: 'draft'
      class_option :description

      def init_source
        @source = Amiba::Source::Entry.new(options[:category].to_sym,
                                           name,
                                           format,
                                           options,
                                           "h1. New post\n")
      end

      def should_not_exist
        unless @source.new?
          raise Thor::Error.new("Error: An entry called '#{name}' already exists.")
        end
      end

      def should_be_valid
        unless @source.valid?
          raise Thor::Error.new("Error:" + @source.errors)
        end
      end

      def save_entry
        @source.save do |filename, file_data|
          create_file filename, file_data
        end
      end

      def add_to_git
        add_and_commit @source.filename
      end

      protected

      no_tasks do
        def name
          options[:title].parameterize
        end
      end
    end

    # Thor task to mark an entry published.
    class Publish < Thor::Group
      include Amiba::Generator
      include Amiba::Repo

      namespace :"entry:publish"
      argument :name
      argument :format, default: 'markdown'
      class_option :category, required: true

      def init_source
        @source = Amiba::Source::Entry.new(options[:category].to_sym, name, format)
      end

      def should_exist
        if @source.new?
          raise Thor::Error.new("Error: Can't publish an entry that doesn't exist.")
        end
      end

      def should_not_be_published
        if @source.state == "published"
          raise Thor::Error.new("Entry already published")
        end
      end

      def save_page
        @source.state = "published"
        @source.save do |filename, file_data|
          remove_file filename, :verbose => false
          create_file filename, file_data, :verbose => false
          say_status :published, filename, :green
        end
      end

      def add_to_git
        add_and_commit @source.filename, "Published #{@source.filename}"
      end

    end


  end
end
