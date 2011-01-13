module Amiba
  module Post

    class Create < Thor::Group
      include Amiba::Generator

      namespace :"post:create"
    end

    # Encapsulates a post source file
    class Source
      attr_reader :name
      
    end

    # Superclass of all model classes - provides a few base services
    class Model
      class << self
        protected
        
        def dir
          "#{Amiba::POSTS_DIR}/#{self.name.demodulize.pluralize}"
        end
      end
    end

    # Generate classes for each post type found under the Amiba project
    # posts directory
    Dir.glob("#{Amiba::POSTS_DIR}/*").each do |post_dir|
      klass_const = File.basename(post_dir).singularize.titleize
      klass = Class.new(Model) do
        class << self
          def all
            Dir.glob(dir + '/*') .each do |post|
              puts post
            end
          end
        end
      end
      Amiba::Post.const_set(klass_const, klass)
    end
  end
end
