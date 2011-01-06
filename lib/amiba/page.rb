require 'yaml'

module Amiba
  module Page

    class Create < Thor::Group
      include Amiba::Generator

      namespace :"page:create"
      argument :name
      class_option :layout, :default => "default"
      class_option :format, :default => :haml
      class_option :title, :required => true, :default => "Default title"
      class_option :description, :default => "Default description"
      class_option :type, :default => "plain"

      def create_page
        raise Thor::Error.new("#{name} has already been created.") if exists?
        
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

        def exists?
          !Dir.glob("pages/#{name}.*").empty?
        end
      end

    end

    class Destroy < Thor::Group
      include Amiba::Generator

      namespace :"page:destroy"
      argument :name
      class_option :format, :default => :haml

      def page
        Dir.glob("pages/#{name}.*") do |fn|
          if ask("Are you sure you want to delete #{fn}? This is irreversible (y/n): ")
            remove_file(fn)
          end
        end
      end
      
    end

    class Build < Thor::Group
      include Amiba::Generator

      namespace :"page:build"
      argument :page
      
      def load_file_contents
        File.open(page_filename) do |f|
          documents = YAML.load(f)
          @metadata, @content = documents
        end
      end

      no_tasks do
        def page_filename
          Dir.glob("pages/#{page}.*").first
        end
      end
      
    end

    class List < Thor::Group
      include Amiba::Generator

      namespace :"page:list"

      def list
        Dir.glob("pages/*").each {|p| say File.basename(p)}
      end
    end
    
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
