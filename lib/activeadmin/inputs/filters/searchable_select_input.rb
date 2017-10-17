module ActiveAdmin
  module Inputs
    module Filters
      # Searchable select input type for ActiveAdmin filters.
      #
      # @see ActiveAdmin::Select2::SelectInputExtension for list of
      # available options.
      class SearchableSelectInput < SelectInput
        include SearchableSelect::SelectInputExtension
      end
    end
  end
end
