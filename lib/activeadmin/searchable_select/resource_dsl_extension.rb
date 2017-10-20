module ActiveAdmin
  module SearchableSelect
    # Mixin for ActiveAdmin resource DSL
    module ResourceDSLExtension
      # Define a collection action to serve options JSON data for
      # searchable selects.
      #
      # @param scope [ActiveRecord::Relation, Proc] Either a
      #   collection of records to create options for or a proc
      #   returning such a collection. Procs are evaluated in the
      #   context of the collection action defined by this
      #   method. Procs can optionally take a single `params` argument
      #   containing data defined under the `params` key of the
      #   input's `ajax` option.
      #
      # @param text_attribute [Symbol] Name of method to call on record
      #   to get display name.
      #
      # @param name [Symbol] Optional collection name if helper is
      #   used multiple times within one resource.
      def searchable_select_options(name: :all, **options)
        option_collection = OptionCollection.new(name, options)
        config.searchable_select_option_collections[name] = option_collection

        collection_action(option_collection.collection_action_name) do
          render(json: option_collection.as_json(self, params))
        end
      end
    end
  end
end
