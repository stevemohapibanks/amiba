require 'spec_helper'

describe Amiba::Source do
  it "should be true" do
    true.should == true
  end

  before(:each) do
    @klass = Class.new do
      include Amiba::Source
      class_eval "def self.name; 'Amiba::Source::Page'; end"
    end
    @klass.send :metadata_fields, :layout, :format, :title, :description, :category
  end

  describe "generating a source filename" do
    before(:each) do
      @metadata = {
        layout: 'default', format: 'haml', title: 'Title',
        description: 'Description', category: 'plain'
      }
      @content = "h1. Title.\np. Body"
    end
    describe "when no source file exists" do
      before(:each) do
        @page = @klass.new("home", @metadata, @content)
      end
      it "should generate pages/home as the source filename" do
        @page.source_filename.should == 'pages/home'
      end
      it "should not exist" do
        @page.new?.should == true
      end
      it "should return metadata values" do
        @page.layout.should == 'default'
        @page.format.should == 'haml'
        @page.title.should == 'Title'
        @page.description.should == 'Description'
        @page.category.should == 'plain'
      end
    end
    describe "when a source file exists" do
      describe "with no new metadata" do
        before(:each) do
          @page = @klass.new('existing_page')
        end
        it "should generate pages/existing_page as the source filename" do
          @page.source_filename.should == 'pages/existing_page'
        end
        it "should not be new" do
          @page.new?.should == false
        end
        it "should load the metadata" do
          @page.layout.should == "custom"
          @page.format.should == "markdown"
          @page.title.should == "Title"
        end
      end

      describe "with new metadata" do
        before(:each) do
          @metadata = {title: 'New title', description: 'New description'}
          @page = @klass.new('existing_page', @metadata)
        end
        it 'should merge the metadata, with new metadata taking priority' do
          @page.layout.should == 'custom'
          @page.title.should == 'New title'
          @page.description.should == 'New description'
        end
      end
    end
  end

end
