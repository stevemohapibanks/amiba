require 'spec_helper'
require 'fileutils'

describe Amiba::Scope do

  before(:each) do
    @page = Amiba::Source::Page.new('simple_page',
                                    'haml',
                                    {title: "Simple Title", description: "Simple Description"},
                                    "<h1>Title</h1>\n<p>Body</p>")
    @scope = Amiba::Scope.new(@page)
  end

  it "should expose the page title" do @scope.title.should == "Simple Title" end
  it "should expose the page description" do @scope.description.should == "Simple Description" end

  describe "rendering" do
    it "should find a h1 tag in the output" do
      @scope.content.should have_tag('h1', 'Title')
    end
    it "should find a p tag in the output" do
      @scope.content.should have_tag('p', 'Body')
    end
  end
end
