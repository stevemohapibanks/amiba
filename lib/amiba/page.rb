module Amiba
  module Page

    class Create < Amiba::Generator

      argument :name
      class_option :with_layout, :default => "default"
      class_option :title, :default => "Title"
      class_option :description, :default => "Description"

      def page
        @page = {:title => options[:title], :description => options[:description]}
        template "templates/skeletons/page.md.tt", "pages/#{name}.md"
      end

    end

    class Destroy < Amiba::Generator

      argument :name

      def page
        remove_file "pages/#{name}.md" if ask("Are you sure? This is irreversible (y/n): ")
      end
      
    end
  end
end
