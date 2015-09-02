require 'rails/railtie'

module LazyObservers
  class Railtie < Rails::Railtie
    config.to_prepare do
      LazyObservers.clear
    end
  end
end
