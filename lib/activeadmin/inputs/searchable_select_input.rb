module ActiveAdmin
  module Inputs
    # Searchable select input type for ActiveAdmin filters.
    #
    # @see ActiveAdmin::Select2::SelectInputExtension for list of
    # available options.
    class SearchableSelectInput < Formtastic::Inputs::SelectInput
      include SearchableSelect::SelectInputExtension
    end
  end
end
