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

      def staged_filename
        File.join(Amiba::Configuration.staged_dir, filename)
      end
      alias_method :output_filename, :staged_filename

    end
  end
end
