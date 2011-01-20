require 'spec_helper'

describe Amiba::Configuration do

  it "should load defaults from .amiba file" do
    Amiba::Configuration.default_page_format.should == "haml"
    Amiba::Configuration.default_entry_format.should == "markdown"
  end
  it "should be able to set configuration settings" do
    Amiba::Configuration.default_entry_format = "haml"
    Amiba::Configuration.default_entry_format.should == "haml"
  end

end
