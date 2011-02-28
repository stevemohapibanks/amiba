module Amiba
  module Source
    module EntryFinder
      include Amiba::Repo

      def all(args={})
        category = args[:category]
        state = args[:state] || "published"

        all_entries.map { |cat, name|
          ext = File.extname name
          Amiba::Source::Entry.new(cat, File.basename(name, ext), ext.gsub(/^\./,""))
        }.select {|entry|
          (category == nil || entry.category == category.singularize) &&
          (state == "any" || entry.state == state)
        }
      end

      protected
      
      def all_entries
        sorted_entries.map do |name|
          name =~ /.*\/(.*)\/(.*)/ ? [$1.singularize.to_sym, $2] : nil
        end.compact
      end

      def sorted_entries
        entries.sort do |a,b|
          last_commit_date(a) <=> last_commit_date(b)
        end
      end

      def entries
        Dir.glob('entries/*/*').select {|f| !repo.log(f).empty?}
      end
    end
  end
end
