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
      #   input's `ajax` option. Required.
      #
      # @param text_attribute [Symbol] Name of attribute to use as
      #   display name and to filter by search term.
      #
      # @param display_text [Proc] Takes the record as
      #   parameter. Required if `text_attribute` is not present.
      #
      # @param filter [Proc] Takes the search term and an Active
      #   Record scope as parameters and needs to return a scope of
      #   filtered records. Required if `text_attribute` is not
      #   present.
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
