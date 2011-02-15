require 'spec_helper'

describe Amiba::Source::EntryCache do

  describe "finding all entries" do
    before(:each) do
      @entries = []
      [:post, :job].each do |entry_category|
        3.times do
          entry = Amiba::Source::Entry.new(entry_category,
                                           Factory.next(:entry_name),
                                           Factory.attributes_for(:entry, format: 'markdown'),
                                           "Content")
          entry.save do |filename, file_data|
            File.open(filename, 'w') {|f| f.write(file_data)}
          end
          @entries << entry
        end
      end
    end
    after(:each) do
      @entries.each { |e| File.delete(e.filename) }
    end
    describe "with no options" do
      it "should find 6 entries" do
        Amiba::Source::EntryCache.all.count.should == 6
      end
    end
    describe "with an entry category specified" do
      [:post, :job].each do |category|
        it "should find 3 #{category.to_s} entries" do
          Amiba::Source::EntryCache.all(category).each do |e|
            e.should be_instance_of(Amiba::Source::Entry)
            e.category.should == category
          end
        end
      end
      
    end
  end
end
