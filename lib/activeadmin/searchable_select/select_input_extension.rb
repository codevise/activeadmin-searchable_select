module ActiveAdmin
  module SearchableSelect
    module SelectInputRegistration
      def input_html_options
        super.merge('data-searchable-select-default-name' => input_html_options_name)
      end

      def to_html
        (builder.instance_variable_get(:@searchable_select_inputs) ||
          builder.instance_variable_set(:@searchable_select_inputs, {}))[method.to_s] = self
        super
      end

      protected

      def selected_values
        @object.send(input_name) if @object
      end

      def read_only?
        options.dig(:input_html, :disabled)
      end
    end

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
    # - `path_params`: Hash of parameters, which would be passed to the
    #   dynamic collection path generation for the resource.
    #   e.g `admin_articles_path(path_params)`
    #
    # If the `ajax` option is present, the `collection` option is
    # ignored.
    module SelectInputExtension
      # @api private
      def input_html_options
        options = super
        options[:class] = [options[:class], 'searchable-select-input'].compact.join(' ')
        options.merge('data-ajax-url' => ajax_url).merge(dependency_html_options)
      end

      # @api private
      def collection_from_options
        return super unless ajax?

        if SearchableSelect.inline_ajax_options
          all_options_collection
        else
          selected_value_collection
        end
      end

      def select_html
        return super if dependencies.empty?

        builder.hidden_field(input_name, value: '', id: nil, multiple: multiple?,
                                         disabled: read_only?) + super
      end

      protected

      def read_only?
        super || dependencies.values.any? { |input| input.read_only? }
      end

      private

      def ajax?
        options[:ajax] || dependencies.any?
      end

      def dependencies
        @dependencies ||= Array.wrap(options[:depends_on]).compact
                               .map { |dep| dep.is_a?(Hash) ? dep : { dep => dep } }
                               .reduce({}, :merge)
                               .transform_values { |attribute| dependency_input(attribute) }
      end

      def dependency_input(attribute)
        rendered_inputs[attribute.to_s] ||
          self.class.new(builder, template, object, object_name, attribute,
                         dependency_input_options(attribute))
      end

      def dependency_input_options(attribute)
        return {} unless builder.is_a?(ActiveAdmin::Filters::FormBuilder)

        filter_options = template.active_admin_config.filters.fetch(attribute.to_sym, {})
        return filter_options unless filter_options[:input_html].is_a?(Proc)

        filter_options.merge(input_html: template.instance_exec(&filter_options[:input_html]))
      end

      def rendered_inputs
        builder.instance_variable_get(:@searchable_select_inputs) ||
          builder.instance_variable_set(:@searchable_select_inputs, {})
      end

      def dependency_values
        dependencies.transform_values { |input| input.selected_values }
      end

      def dependency_html_options
        return {} if dependencies.empty? || options.dig(:input_html, :disabled)

        names = dependencies.transform_values { |input| input.input_html_options[:name] }
        disabled = dependencies.values.any? do |input|
          value = input.selected_values
          input.input_html_options[:disabled] || value.nil? || value.try(:empty?)
        end

        { 'data-searchable-select-depends-on' => names.to_json,
          disabled: disabled }
      end

      def ajax_url
        return unless ajax?
        [ajax_resource.route_collection_path(path_params),
         '/',
         option_collection.collection_action_name,
         '?',
         ajax_params.to_query].join
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

      def option_collection_scope
        option_collection.scope(template, path_params.merge(ajax_params).merge(dependency_values))
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

      def path_params
        ajax_options.fetch(:path_params, {})
      end

      def ajax_options
        options[:ajax].is_a?(Hash) ? options[:ajax] : {}
      end
    end
  end
end

Formtastic::Inputs::SelectInput.prepend ActiveAdmin::SearchableSelect::SelectInputRegistration
