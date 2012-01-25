require 'thor'
require 'thor/group'

module Amiba

  class Runner < Thor
  end

  module Generator

    def self.included(base)
      base.send :include, Thor::Actions
      base.send :extend, ClassMethods
    end

    module ClassMethods
      def source_root(path = nil)
        default_source_root
      end
      
      def default_source_root
        File.dirname(File.expand_path(File.join(__FILE__, "..")))
      end      
    end
  end

  class Group < Thor::Group
    include Generator
  end

end

require 'amiba/all'
