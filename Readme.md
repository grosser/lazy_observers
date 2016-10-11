### DEPREACTED ... [kill observers](https://grosser.it/2013/01/04/kill-activerecord-observers) instead!

Make Activerecord Observers not load observed models -> faster/safer environment boot.
 - faster tests + console
 - able to boot environment without/with empty/with old database

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
      klass.class_eval do
        ... funky hacks ...
      end
    end

### Catch models that are loaded in application startup.

    LazyObservers.debug_active_record_loading

`script/console` or `rails c`

### Verify you did not misspell
Loads all classes registered via observers, to make sure you did not misspell</br>
(negates the effect of lazyness, so only use for debugging)


    LazyObservers.check_classes

TIPS
====
 - .on_load is called before all methods are defined on the baseclass, so they might not be defined
 - do not use observe and lazy_observe in the same observer (and if you have to, use observe after lay_observe)
 - do not use Model classes with class-methods of the observer e.g. class FooObserver; Foo.something{}; def after_update; end; end

Author
======
[Michael Grosser](http://grosser.it)<br/>
michael@grosser.it<br/>
License: MIT<br/>
[![Build Status](https://secure.travis-ci.org/grosser/lazy_observers.png)](http://travis-ci.org/grosser/lazy_observers)
