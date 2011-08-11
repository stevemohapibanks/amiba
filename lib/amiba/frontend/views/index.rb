module Protozoa
  module Views
    class Index < Layout
      attr_reader :entries, :ref

      def title
        "All pages for #{Amiba::Configuration.site_name}"
      end

      def has_entries
        !@entries.empty?
      end
      
      def no_entries 
        @entries.empty?
      end
    end
  end
end
