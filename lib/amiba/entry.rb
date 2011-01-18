module Amiba
  module Entry

    class Create < Thor::Group
      include Amiba::Generator

      namespace :"entry:create"
      class_option :category, required: true
      class_option :title, required: true
      class_option :description
      class_option :format, default: 'markdown'

      def init_source
        @source = Amiba::Source::Entry.new(name, options, "h1. New post\n")
      end

      def should_not_exist
        unless @source.new?
          raise Thor::Error.new("Error: An entry called '#{name} already exists.")
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

      protected

      no_tasks do
        def name
          options[:title].parameterize
        end
      end
    end

  end
end
