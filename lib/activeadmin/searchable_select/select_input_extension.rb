module ActiveAdmin
  module SearchableSelect
    # Mixin for searchable select inputs.
    #
    # Supports the same options as inputs of type `:select`.
    #
    # Adds support for an `ajax` option to fetch options data from a
    # JSON endpoint. Pass either `true` to use defaults or a hash
    # containing some of the following options:
    #
    # - `resource`: ActiveRecord model class of ActiveAdmin resource
    #    which provides the collection action to fetch options
    #    from. By default the resource is auto detected via the name
    #    of the input attribute.
    #
    # - `collection_name`: Name passed to the
    #   `searchable_select_options` method that defines the collection
    #   action to fetch options from.
    #
    # - `params`: Hash of query parameters that shall be passed to the
    #   options endpoint.
    #
    # If the `ajax` option is present, the `collection` option is
    # ignored.
    module SelectInputExtension
      # @api private
      def input_html_options
        options = super
        options[:class] = [options[:class], 'searchable-select-input'].compact.join(' ')
        options.merge('data-ajax-url' => ajax_url)
      end

      # @api private
      def collection_from_options
        return super unless options[:ajax]

        if SearchableSelect.inline_ajax_options
          all_options_collection
        else
          selected_value_collection
        end
      end

      private

      def ajax_url
        return unless options[:ajax]
        template.polymorphic_path([template.active_admin_namespace.module_name, ajax_resource_class],
                                  action: option_collection.collection_action_name,
                                  **ajax_params)
      end

      def all_options_collection
        option_collection_scope.all.map do |record|
          option_for_record(record)
        end
      end

      def selected_value_collection
        selected_records.collect { |s| option_for_record(s) }
      end

      def option_for_record(record)
        [option_collection.display_text(record), record.id]
      end

      def selected_records
        @selected_records ||=
          if selected_values
            option_collection_scope.where(id: selected_values)
          else
            []
          end
      end

      def selected_values
        @object.send(input_name) if @object
      end

      def option_collection_scope
        option_collection.scope(template, ajax_params)
      end

      def option_collection
        ajax_resource
          .searchable_select_option_collections
          .fetch(ajax_option_collection_name) do
          raise("No option collection named '#{ajax_option_collection_name}' " \
                "defined in '#{ajax_resource_class.name}' admin.")
        end
      end

      def ajax_resource
        @ajax_resource ||=
          template.active_admin_namespace.resource_for(ajax_resource_class) ||
          raise("No admin found for '#{ajax_resource_class.name}' to fetch " \
                'options for searchable select input from.')
      end

      def ajax_resource_class
        ajax_options.fetch(:resource) do
          raise_cannot_auto_detect_resource unless reflection
          reflection.klass
        end
      end

      def raise_cannot_auto_detect_resource
        raise('Cannot auto detect resource to fetch options for searchable select input from. ' \
              "Explicitly pass class of an ActiveAdmin resource:\n\n" \
              "  f.input(:custom_category,\n" \
              "          type: :searchable_select,\n" \
              "          ajax: {\n" \
              "            resource: Category\n" \
              "          })\n")
      end

      def ajax_option_collection_name
        ajax_options.fetch(:collection_name, :all)
      end

      def ajax_params
        ajax_options.fetch(:params, {})
      end

      def ajax_options
        options[:ajax] == true ? {} : options[:ajax]
      end
    end
  end
end
