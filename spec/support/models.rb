require 'database_cleaner'

class User < ActiveRecord::Base; end

class Category < ActiveRecord::Base
  belongs_to :created_by, class_name: 'User'
end

class Post < ActiveRecord::Base
  belongs_to :category
  belongs_to :user

  scope(:published, -> { where(published: true) })
end

RSpec.configure do |config|
  config.after do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end
end
