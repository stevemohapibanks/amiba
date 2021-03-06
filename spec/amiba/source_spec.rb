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
    @klass.send :metadata_fields, :layout, :title, :description, :category, :state
  end

  describe "initialising a source instance" do
    before(:each) do
      @metadata = {
        layout: 'default', title: 'Title',
        description: 'Description', category: 'plain', state: 'draft'
      }
      @content = "h1. Title.\np. Body"
    end
    describe "when no source file exists" do
      before(:each) do
        @page = @klass.new("home", "haml", @metadata, @content)
      end
      it "should generate pages/home.haml as the source filename" do
        @page.filename.should == 'pages/home.haml'
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
        @page.state.should == 'draft'
      end
    end
    describe "when a source file exists" do
      before(:each) do
        pg = @klass.new('existing_page',
                        'markdown',
                        {title: "Title", layout: 'custom'},
                        "Content")
        pg.save do |fn, fd|
          Dir.mkdir(File.dirname(fn))
          File.open(fn, 'w+') {|f| f.write(fd) }
        end
      end
      describe "with no new metadata" do
        before(:each) do
          @page = @klass.new('existing_page', 'markdown')
        end
        it "should generate pages/existing_page.markdown as the source filename" do
          @page.filename.should == 'pages/existing_page.markdown'
        end
        it "should not be new" do
          @page.new?.should == false
        end
        it "should load the metadata" do
          @page.format.should == "markdown"
          @page.title.should == "Title"
          @page.layout.should == "custom"
        end
      end

      describe "with new metadata" do
        before(:each) do
          @metadata = {title: 'New title', description: 'New description'}
          @page = @klass.new('existing_page', 'markdown', @metadata)
        end
        it 'should merge the metadata, with new metadata taking priority' do
          @page.layout.should == 'custom'
          @page.title.should == 'New title'
          @page.description.should == 'New description'
        end
      end
    end
  end

  describe "saving an instance" do
    before(:each) do
      @page = @klass.new('new_page', 'haml',
                         {layout: 'default', title: 'Title',
                           description: 'Description', category: 'plain'},
                         "Some content")
    end
    describe "when the source is valid" do
      it "should save the source file" do
        @page.save do | filename, data |
          filename.should == @page.filename
        end.should == true
      end
    end
    describe "when the source is invalid" do
      it "should not save" do
        @page.should_receive(:valid?).and_return(false)
        @page.save do | filename, data |
          fail "Should not try and save"
        end.should == false
      end
    end
  end
end

describe Amiba::Source::Page do

  describe "validating metadata" do
    before(:each) do
      @page = Amiba::Source::Page.new('new_page', 'haml',
                                      {layout: 'default', title: 'Title',
                                        description: 'Description', category: 'plain', state: 'draft'},
                                      "Some content")
    end
    [:title, :description, :layout, :format, :category, :state].each do |field|
      it "should have a #{field.to_s}" do
        @page.send(:"#{field}=", nil)
        @page.errors[:"#{field}"].should_not be_nil
      end
    end
    %w{haml markdown}.each do |format|
      it "should accept #{format} as a valid format" do
        @page.format = format
        @page.should be_valid
      end
    end
    it "should reject an invalid format" do
      @page.format = "invalid"
      @page.errors[:format].should_not be_nil
    end
    it "should have an output filename" do
      @page.output_filename.should == 'site/public/new_page.html'
    end
  end
end

describe Amiba::Source::Layout do
  describe "validating metadata" do
    before(:each) do
      @layout = Amiba::Source::Layout.new('new_layout', 'haml')
    end
    it "should have a format" do
      @layout.format = nil
      @layout.errors[:layout].should_not be_nil
    end
    %w{haml markdown}.each do |format|
      it "should accept #{format} as a valid format" do
        @layout.format = format
        @layout.should be_valid
      end
    end
    it "should reject an invalid format" do
      @layout.format = "invalid"
      @layout.errors[:format].should_not be_nil
    end
  end
  
end
