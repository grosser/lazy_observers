Makes Activerecord Observers lazy, do not load model on startup and only listen once a model got loaded.

Install
=======

    gem install lazy_observers

Usage
=====

    class FooObserver < ActiveRecord::Observer
      lazy_observe "User", "Foo::Bar"

      ...
    end

### Extend models from gems after they are loaded

    LazyObservers.on_load("Arturo::Feature") do |klass|
      Arturo::Feature.class_eval do
        ... funky hacks ...
      end
    end

### Debug which classes get loaded

    LazyObservers.debug_active_record_loading

Author
======
[Michael Grosser](http://grosser.it)<br/>
michael@grosser.it<br/>
License: MIT<br/>
[![Build Status](https://secure.travis-ci.org/grosser/lazy_observers.png)](http://travis-ci.org/grosser/lazy_observers)
