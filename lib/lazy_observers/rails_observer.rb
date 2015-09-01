if ActiveRecord::VERSION::MAJOR < 4
  require 'active_record/observer'
else
  begin
    require 'rails/observers/active_model/observing'
    require 'rails/observers/activerecord/observer'
  rescue LoadError => _
    $stderr.puts(<<-MSG)
ERROR: Failed loading rails-observers dependencies.
If you are using Rails 4+, make sure `gem 'rails-observers'` is in your Gemfile.
    MSG
    raise
  end
end
