require "spec_helper"
require File.expand_path("../app/user_observer", __FILE__)
require File.expand_path("../app/post_observer", __FILE__)
require File.expand_path("../app/product_observer", __FILE__)

describe LazyObservers do
  it "has a VERSION" do
    LazyObservers::VERSION.should =~ /^[\.\da-z]+$/
  end

  it "does not load models when being loaded" do
    defined?(UserObserver).should == "constant"
    UserObserver.instance
    defined?(User).should == nil
  end

  it "makes the observer observe nothing" do
    PostObserver.instance.observed_classes.should == Set.new
  end

  it "listens to events after models are loaded" do
    PostObserver.instance.called.should == []
    defined?(Post).should == nil
    require File.expand_path("../app/post", __FILE__)
    post = Post.create!
    PostObserver.instance.called.should == [[:after_create, [post]], [:after_update, [post]]]
  end

  it "listens to events if models are loaded before observer" do
    defined?(MovieObserver).should == nil
    require File.expand_path("../app/movie_observer", __FILE__)
    MovieObserver.instance.called.should == []
    movie = Movie.create!
    MovieObserver.instance.called.should == [[:after_create, [movie]], [:after_update, [movie]]]
  end

  it "observes inherited classes" do
    defined?(Product).should == nil
    defined?(InheritedProduct).should == nil
    require File.expand_path("../app/products", __FILE__)

    # no duplicates
    ProductObserver.instance.observed_classes.flatten.should == Set.new([Product, InheritedProduct])

    # for inherited
    ProductObserver.instance.called.should == []
    product = InheritedProduct.create!
    ProductObserver.instance.called.should == [[:after_create, [product]], [:after_update, [product]]]

    ProductObserver.instance.called.clear

    # for normal
    ProductObserver.instance.called.should == []
    product = Product.create!
    ProductObserver.instance.called.should == [[:after_create, [product]], [:after_update, [product]]]
  end

  it "blows up when you pass it a class, since this means you did not understand the concept" do
    expect{
      require File.expand_path("../app/stupid_observer", __FILE__)
    }.to raise_error(/not classes or symbols/i)
  end

  it "calls callback when matching class is loaded" do
    loaded = []
    LazyObservers.on_load("Group") do |klass|
      loaded << klass
    end
    require File.expand_path("../app/groups", __FILE__)
    loaded.should == [Group]
  end
end
