require 'spec_helper'

describe Symbol do

  describe "pluralize" do
    it "should return the same symbol if already a plural" do
      :tests.pluralize.should == :tests
    end
    it "should return a pluralized symbol if not already a plural" do
      :test.pluralize.should == :tests
    end
  end

  describe "singularize" do
    it "should return the same symbol if already singularized" do
      :test.singularize.should == :test
    end
    it "should return a singularized symbol if a plural" do
      :tests.singularize.should == :test
    end

  end
end
