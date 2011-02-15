require 'spec_helper'

describe Amiba::Source::EntryCache do

  describe "finding all entries" do
    before(:each) do
      @entries = []
      5.times do
        entry = Amiba::Source::Entry.new(:post,
                                         Factory.next(:entry_name),
                                         Factory.attributes_for(:entry, format: 'markdown'),
                                         "Content")
        entry.save do |filename, file_data|
          File.open(filename, 'w') {|f| f.write(file_data)}
        end
        @entries << entry
      end
    end
    after(:each) do
      @entries.each { |e| File.delete(e.filename) }
    end
    describe "with no options" do
      it "should find 5 entries" do
        Amiba::Source::EntryCache.all.count.should == 5
      end
      it "should have 5 'post' entries" do
        Amiba::Source::EntryCache.all.each do |e|
          e.should be_instance_of(Amiba::Source::Entry)
          e.category.should == :post
        end
      end
    end
  end
end
