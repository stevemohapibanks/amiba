require 'spec_helper'

describe Amiba::Source::Entry do

  describe "creating an Entry" do
    describe "that doesn't already exist" do
      before(:each) do
        @entry = Amiba::Source::Entry.new(:post, 'new_post', 'haml',
                                          Factory.attributes_for(:entry),
                                          "Some content")
      end
      describe "validating metadata" do
        it "should have a title" do
          @entry.title = nil
          @entry.valid?.should be_false
          @entry.errors[:title].should_not be_nil
        end
      end
      it "should have a source filename" do
        @entry.filename.should == 'entries/posts/new_post.haml'
      end
      it "should have a staged filename" do
        @entry.staged_filename.should == "staged/entries/posts/new_post.haml"
      end
      it "should have an output filename" do
        @entry.output_filename.should == 'site/public/posts/new_post.html'
        @entry.category = "entry"
        @entry.output_filename.should == 'site/public/entries/new_post.html'
      end
      it "should have a link" do
        @entry.link.should == "/posts/new_post.html"
      end
      it "should correctly escape the link" do
        @entry.category = "some entries"
        @entry.link.should == "/some%20entries/new_post.html"
      end
    end

    describe "that already exists" do
      include Amiba::Repo
      
      before(:each) do
        @entry = Amiba::Source::Entry.new(:post,
                                          Factory.next(:entry_name),
                                          'markdown',
                                          Factory.attributes_for(:entry),
                                          "Content")
        @entry.save do |filename, file_data|
          FileUtils.mkdir_p File.dirname filename
          File.open(filename, 'w') {|f| f.write(file_data)}
          add_and_commit(filename)
        end
      end
      it "should create an Entry object" do
        e = Amiba::Source::Entry.new(:post, @entry.name, @entry.format)
        puts e.inspect
        e.should be_instance_of(Amiba::Source::Entry)
        e.title.should == "Title"
      end
      after(:each) do
        File.delete(@entry.filename)
      end
    end
  end

  describe "finding all entries" do
    include Amiba::Repo

    before(:each) do
      @entries = []
      [:post, :job].each do |entry_category|
        ["published", "draft"].each do |state|
          3.times do
            entry = Amiba::Source::Entry.new(entry_category,
                                             Factory.next(:entry_name),
                                             'markdown',
                                             Factory.attributes_for(:entry, state: state),
                                             "Content")
            entry.save do |filename, file_data|
              FileUtils.mkdir_p(File.dirname(filename))
              File.open(filename, 'w') {|f| f.write(file_data)}
              add_and_commit(filename)
            end
            @entries << entry
          end
        end
      end
    end
    describe "with no options" do
      it "should find 6 entries" do
        Amiba::Source::Entry.all.count.should == 6
      end
    end
    describe "searching for entries in any state" do
      it "should find 12 entries" do
        Amiba::Source::Entry.all(state: "any").count.should == 12
      end
    end
    describe "with an entry category specified" do
      [:post, :job].each do |category|
        it "should find 3 #{category.to_s} entries" do
          Amiba::Source::Entry.all(category: category).each do |e|
            e.should be_instance_of(Amiba::Source::Entry)
            e.category.should == category
          end
        end
      end
    end
  end
end
