module Amiba
  module Source
    module EntryCache

      class << self
        def all(*args)
          all_entry_pairs.map { |cat, name| Amiba::Source::Entry.new(cat, name) }
        end

        protected

        def all_entry_pairs
          all_entry_files.map do |name|
            name =~ /.*\/(.*)\/(.*)/ ? [$1.singularize.to_sym, $2] : nil
          end.compact
        end
        
        def all_entry_files
          Dir.glob('entries/*/*')
        end
      end

    end
  end
end
