require "active_record"

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => ":memory:",
)

# create tables
ActiveRecord::Schema.define(:version => 1) do
  create_table :users do |t|
    t.string :name
  end

  create_table :posts do |t|
    t.string :title
  end

  create_table :movies do |t|
    t.string :title
  end

  create_table :products do |t|
    t.string :title
  end
end
