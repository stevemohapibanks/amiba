module Amiba
  module Site

    class Generate < Thor::Group
      include Amiba::Generator

      namespace :"site:generate"

      def self.source_root
        Dir.pwd
      end

      def cleardown
        remove_dir Amiba::Configuration.site_dir
        remove_dir Amiba::Configuration.staged_dir
      end

      def create_site_structure
        empty_directory Amiba::Configuration.site_dir
      end
      
      def copy_javascript
        directory "public/js", File.join(Amiba::Configuration.site_dir, "public/js")
      end

      def copy_images
        directory "public/images", File.join(Amiba::Configuration.site_dir, "/public/images")
      end
      
      def copy_css
        directory "public/css", File.join(Amiba::Configuration.site_dir, "/public/css")
      end
      
      def process_and_copy_sass
        Dir.glob('public/css/*.scss').each do |scss_file|
          create_file "site/css/#{File.basename(scss_file).gsub('scss', 'css')}"
          Tilt.new(scss_file).render
        end
      end
    
      def build_pages
        Dir.glob('pages/*').each do |page_file|
          ext = File.extname page_file
          build_page(File.basename(page_file, ext), ext.sub(/^./,""))
        end
      end
      
      private
      def build_page(name, format)
        @page = Amiba::Source::Page.new(name, format)
        @layout = Amiba::Source::Layout.new(@page.layout, @page.format)
        create_file(@page.staged_filename) do @page.content end
        create_file(@layout.staged_filename) do @layout.content end
        create_file(@page.output_filename) do
          Tilt.new(@layout.staged_filename).render(Amiba::Scope.new(@page))
        end
      end

    end
  end
end
