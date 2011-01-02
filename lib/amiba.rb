require 'thor'
require 'thor/group'

module Amiba


    class Generator < Thor::Group
      include Thor::Action
    
      class << self
        
        def source_root(path = nil)
          default_source_root
        end
        
        def default_source_root
          File.dirname(File.expand_path(File.join(__FILE__, "..")))
        end
        
        def in_amiba_application?
          File.exist? ".amiba"
        end
      end
    end


  class Create < Generator

    argument :name
    class_option :default_page, :default => "home"

    def create_project_structure
      %w{pages posts layouts}.each {|dirname|
        directory File.join("templates", dirname), File.join(name, dirname)
      }
      create_file(File.join(name, ".amiba"))
    end

    def create_default_page
      Dir.chdir(name) do
        require 'amiba/page'
        Amiba::Page::Create.start([options[:default_page]])
      end
    end

  end
end

if Amiba::Generator.in_amiba_application?
  require 'amiba/page'
end

