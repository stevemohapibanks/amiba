require 'spec_helper'
require 'fileutils'

describe Amiba::Scope do

  before(:each) do
    @page = Amiba::Source::Page.new('simple_page')
    @scope = Amiba::Scope.new(@page)
  end

  it "should expose the page title" do @scope.title.should == "Simple Title" end
  it "should expose the page description" do @scope.description.should == "Simple Description" end

  describe "rendering" do
    before(:each) do
      FileUtils.mkdir_p(File.dirname(@page.staged_filename))
      File.open(@page.staged_filename, 'w') do |f| f.write(@page.content) end
    end
    it "should find a h1 tag in the output" do
      @scope.content.should have_tag('h1', 'Title')
    end
    it "should find a p tag in the output" do
      @scope.content.should have_tag('p', 'Body')
    end
    after(:each) do
      File.delete(@page.staged_filename)
    end
  end
end
