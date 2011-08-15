require 'amiba/source'

module Amiba
  module Source
    class Partial
      include Amiba::Source

      attr_accessor :dir, :name
      def initialize(path)
        self.dir, self.name = File.split path
      end

      def filename 
        @filename ||= File.join("pages", @dir, "_#{@name}.haml")
      end

      alias_method :output_filename, :filename

    end
  end
end
