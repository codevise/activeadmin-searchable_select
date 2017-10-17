# Required for ActiveSupport < 5
unless [].respond_to?(:pluck)
  module Enumerable
    def pluck(*keys)
      if keys.many?
        map { |element| keys.map { |key| element[key] } }
      else
        map { |element| element[keys.first] }
      end
    end
  end
end
