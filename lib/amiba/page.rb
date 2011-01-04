module Amiba
  module Page

    class Create < Thor::Group
      include Amiba::Generator

      argument :name
      class_option :layout, :default => "default"
      class_option :format, :default => :haml
      class_option :title, :required => true, :default => "Default title"
      class_option :description, :default => "Default description"

      class_option :root_dir

      def create_page
        @page = {
          :title => options[:title],
          :description => options[:description],
          :layout => options[:layout]
        }
        template(source_filename, target_filename)
      end

      no_tasks do

        def source_filename
          "templates/skeletons/page.#{options[:format].to_s}.tt"
        end
        
        def target_filename
          root_dir = if options[:root_dir]
                       options[:root_dir] + '/'
                     else
                       ''
                     end
          "#{root_dir}pages/#{name}.#{options[:format].to_s}"
        end
      end

    end

    class Destroy < Thor::Group
      include Amiba::Generator

      argument :name

      def page
        remove_file "pages/#{name}.*" if ask("Are you sure? This is irreversible (y/n): ")
      end
      
    end
  end
end
