module ActiveAdmin
  module SearchableSelect
    # @api private
    module ResourceExtension
      def searchable_select_option_collections
        @searchable_select_option_collections ||= {}
      end
    end
  end
end
