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

module RGB
  class Color < ActiveRecord::Base
    self.table_name = :rgb_colors
    has_many :tags, class_name: 'Internal::TagName'
  end
end

module Internal
  class TagName < ActiveRecord::Base
    self.table_name = :internal_tag_names
    belongs_to :color, class_name: 'RGB::Color', foreign_key: :color_id
  end
end

class OptionType < ActiveRecord::Base; end

class OptionValue < ActiveRecord::Base
  belongs_to :option_type
end

class Product < ActiveRecord::Base
  belongs_to :option_type
  has_many :variants
end

class Variant < ActiveRecord::Base
  belongs_to :product
  belongs_to :option_value
end

RSpec.configure do |config|
  config.after do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end
end
