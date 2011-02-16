require 'spec_helper'

describe Amiba::Source::Entry do

  describe "creating an Entry" do
    describe "that doesn't already exist" do
      before(:each) do
        @entry = Amiba::Source::Entry.new(:post, 'new_post',
                                          Factory.attributes_for(:entry, format: 'haml'),
                                          "Some content")
      end
      describe "validating metadata" do
        [:format, :title].each do |metadata_field|
          it "should have a #{metadata_field.to_s}" do
            @entry.send(:"#{metadata_field.to_s}=", nil)
            @entry.valid?.should be_false
            @entry.errors[metadata_field].should_not be_nil
          end
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
    end

    describe "that already exists" do
      before(:each) do
        @entry = Amiba::Source::Entry.new(:post,
                                          Factory.next(:entry_name),
                                          Factory.attributes_for(:entry, format: 'markdown'),
                                          "Content")
        @entry.save do |filename, file_data|
          FileUtils.mkdir_p File.dirname filename
          File.open(filename, 'w') {|f| f.write(file_data)}
        end
      end
      it "should create an Entry object" do
        e = Amiba::Source::Entry.new(:post, @entry.name)
        e.should be_instance_of(Amiba::Source::Entry)
        e.title.should == "Title"
      end
      after(:each) do
        File.delete(@entry.filename)
      end
    end
  end
  
end
