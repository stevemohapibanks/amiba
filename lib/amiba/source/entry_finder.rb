module Amiba
  module Source
    module EntryFinder
      include Amiba::Repo

      def all(category = :all, options = {})
        state = options[:state] || "published"
        
        all_entries.map do |cat, name|
          ext = File.extname name
          Amiba::Source::Entry.new(cat, File.basename(name, ext), ext.gsub(/^\./,""))
        end.select {|entry|
          category == :all || entry.category == category && entry.state == state
        }
      end

      protected
      
      def all_entries
        sorted_entries.map do |name|
          name =~ /.*\/(.*)\/(.*)/ ? [$1.singularize.to_sym, $2] : nil
        end.compact
      end

      def sorted_entries
        Dir.glob('entries/*/*').sort do |a,b|
          last_commit_date(a) <=> last_commit_date(b)
        end
      end
    end
  end
end
