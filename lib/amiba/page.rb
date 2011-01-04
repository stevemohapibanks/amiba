require 'yaml'

module Amiba
  module Page

    class Templates
      class << self
        def haml
          <<-HAML
%h1 Title
%p Body
HAML
        end

        def markdown
          <<-MD
h1. Title
p. Body
MD
        end
      end
    end
    
    class Create < Thor::Group
      include Amiba::Generator

      argument :name
      class_option :layout, :default => "default"
      class_option :format, :default => :haml
      class_option :title, :required => true, :default => "Default title"
      class_option :description, :default => "Default description"

      def create_page
        metadata = options.reject {|k| [:format, :root_dir].include?(k.to_sym)}
        content = Templates.send(options[:format])

        create_file(target_filename) do
          YAML.dump(metadata) + YAML.dump(content)
        end
      end

      no_tasks do
        def target_filename
          "pages/#{name}.#{options[:format].to_s}"
        end
      end

    end

    class Destroy < Thor::Group
      include Amiba::Generator

      argument :name
      class_option :format, :default => :haml

      def page
        remove_file "pages/#{name}.#{options[:format].to_s}" if ask("Are you sure? This is irreversible (y/n): ")
      end
      
    end
  end
end
