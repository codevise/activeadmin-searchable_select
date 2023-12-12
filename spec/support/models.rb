require 'database_cleaner-active_record'

class User < ActiveRecord::Base; end

class Category < ActiveRecord::Base
  belongs_to :created_by, class_name: 'User'

  def self.ransackable_attributes(_auth_object = nil)
    ['name']
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end
end

class Post < ActiveRecord::Base
  belongs_to :category
  belongs_to :user

  scope(:published, -> { where(published: true) })

  def self.ransackable_attributes(_auth_object = nil)
    %w(category_id title)
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end
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

    def self.ransackable_attributes(_auth_object = nil)
      ['color_id']
    end

    def self.ransackable_associations(_auth_object = nil)
      []
    end
  end
end

class OptionType < ActiveRecord::Base; end

class OptionValue < ActiveRecord::Base
  belongs_to :option_type

  def self.ransackable_attributes(_auth_object = nil)
    ['value']
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end
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
