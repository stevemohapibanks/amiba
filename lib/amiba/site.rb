require 'tilt'

module Amiba
  module Site

    class Generate < Thor::Group
      include Amiba::Generator

      namespace :"site:generate"

      def self.source_root
        Dir.pwd
      end

      def create_site_structure
        empty_directory "site"
      end
      
      def copy_javascript
        directory "public/js", "site/public/js"
      end

      def process_and_copy_sass
        Dir.glob('public/css/*.scss').each do |scss_file|
          create_file "site/css/#{File.basename(scss_file).gsub('scss', 'css')}" do
            Tilt.new(scss_file).render
          end
        end
      end

    end
  end
end
