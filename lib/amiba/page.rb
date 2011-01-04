module Amiba
  module Page

    class Create < Thor::Group
      include Amiba::Generator

      argument :name
      class_option :layout, :default => "default"
      class_option :format, :default => :haml
      class_option :title, :required => true, :default => "Default title"
      class_option :description, :default => "Default description"

      class_option :project_dir, :default => Dir.pwd

      def create_page
        @page = {
          :title => options[:title],
          :description => options[:description],
          :layout => options[:layout]
        }
        ext = options[:format].to_s
        template("templates/skeletons/page.#{ext}.tt",
                 "pages/#{name}.#{ext}")
      end

    end

    class Destroy < Thor::Group
      include Amiba::Generator

      def page
        remove_file "pages/#{name}.*" if ask("Are you sure? This is irreversible (y/n): ")
      end
      
    end
  end
end
