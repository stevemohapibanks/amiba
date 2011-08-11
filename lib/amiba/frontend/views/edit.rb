module Protozoa
  module Views
    class Edit < Layout
      include Editable

      attr_reader :page, :content

      def title
        "#{@page.title}"
      end

      def page_name
        "#{@page.title}"
      end

      def is_create_page
        false
      end

      def is_edit_page
        true
      end

      def format
        @format = (@page.format || false) if @format.nil?
        @format.to_s.downcase
      end
    end
  end
end
