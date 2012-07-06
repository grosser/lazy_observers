require 'spec_helper'

describe LazyObservers do
  it "has a VERSION" do
    LazyObservers::VERSION.should =~ /^[\.\da-z]+$/
  end
end
