require 'lazy_observers/version'
require 'active_record'
require 'active_record/observer'

module LazyObservers
  def self.register_observed(klass)
    class_name = klass.name
    loaded << [klass, class_name]
    observers.each do |observer, observed|
      connect!(observer, klass) if observed.include?(class_name)
    end
    (on_loads[class_name]||[]).each{|block| block.call(klass) }
  end

  def self.register_observer(observer, classes)
    observers[observer] = classes
    loaded.each do |klass, name|
      connect!(observer, klass) if classes.include?(name)
    end
  end

  def self.on_load(class_name, &block)
    on_loads[class_name] ||= []
    on_loads[class_name] << block
  end

  # to check you did not specify a class that does not exist
  def self.check_classes
    observers.values.flatten.uniq.each { |klass| klass.constantize }
  end

  def self.debug_active_record_loading
    ActiveRecord::Base.send(:extend, LazyObservers::InheritedDebugger)
  end

  private

  def self.on_loads
    @on_loads ||= {}
  end

  def self.observers
    @observers ||= {}
  end

  def self.loaded
    @loaded ||= []
  end

  def self.connect!(observer, klass)
    observer.instance.observed_class_inherited(klass)
  end
end

descendants = (ActiveRecord::VERSION::MAJOR > 2 ? :descendants : :subclasses)
ActiveRecord::Base.send(descendants).each{|klass| LazyObservers.register_observed(klass) }

ActiveRecord::Observer.class_eval do
  def self.lazy_observe(*classes)
    raise "pass class names, not classes or symbols!" unless classes.all?{|klass| klass.is_a?(String) }
    define_method(:observed_classes) { Set.new }
    LazyObservers.register_observer self, classes
  end
end

module LazyObservers
  module InheritedNotifier
    def inherited(subclass)
      LazyObservers.register_observed subclass
      super
    end
  end

  module InheritedDebugger
    def inherited(subclass)
      @inherited_counter ||= 0
      @inherited_counter += 1
      puts "##{@inherited_counter} #{subclass}"
      puts caller
      puts "-" * 72
      super
    end
  end
end

ActiveRecord::Base.send(:extend, LazyObservers::InheritedNotifier)
