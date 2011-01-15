require 'haml'
require 'sass'
require 'tilt'

module Amiba
  module Site

    class Generate < Thor::Group
      include Amiba::Generator

      namespace :"site:generate"

      def self.source_root
        Dir.pwd
      end

      def cleardown
        remove_dir Amiba::SITE_DIR
        remove_dir Amiba::STAGED_DIR
      end

      def create_site_structure
        empty_directory Amiba::SITE_DIR
      end
      
      def copy_javascript
        directory "public/js", File.join(Amiba::SITE_DIR, "public/js")
      end

      def copy_images
        directory "public/images", File.join(Amiba::SITE_DIR, "/public/images")
      end

      def copy_css
        directory "public/css", File.join(Amiba::SITE_DIR, "/public/css")
      end

      def process_and_copy_sass
        Dir.glob('public/css/*.scss').each do |scss_file|
          create_file "site/css/#{File.basename(scss_file).gsub('scss', 'css')}" do
            Tilt.new(scss_file).render
          end
        end
      end

      def build_pages
        Dir.glob('pages/*').each do |page_file|
          invoke(Amiba::Page::Build,
                 [File.basename(page_file).gsub(File.extname(page_file), '')])
        end
      end

    end
  end
end
