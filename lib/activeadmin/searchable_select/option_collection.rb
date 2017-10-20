module ActiveAdmin
  module SearchableSelect
    # @api private
    class OptionCollection
      def initialize(name, options)
        @name = name
        @scope = extract_scope_option(options)
        @display_text = extract_display_text_option(options)
        @filter = extract_filter_option(options)
      end

      def scope(template, params)
        case @scope
        when Proc
          if @scope.arity.zero?
            template.instance_exec(&@scope)
          else
            template.instance_exec(params, &@scope)
          end
        else
          @scope
        end
      end

      def display_text(record)
        @display_text.call(record)
      end

      def collection_action_name
        "#{@name}_options"
      end

      def as_json(template, params)
        results = records(template, params).map do |record|
          {
            id: record.id,
            text: display_text(record)
          }
        end

        { results: results }
      end

      private

      def records(template, params)
        limit(filter(scope(template, params), params[:term]), params[:limit])
      end

      def filter(scope, term)
        term ? @filter.call(term, scope) : scope
      end

      def limit(scope, count)
        scope.limit(count || 10)
      end

      def extract_scope_option(options)
        options.fetch(:scope) do
          raise('Missing option: scope. ' \
                'Pass the collection of items to render options for.')
        end
      end

      def extract_display_text_option(options)
        options.fetch(:display_text) do
          text_attribute = options.fetch(:text_attribute) do
            raise('Missing option: display_text or text_attribute. ' \
                  'Either pass a proc to determine the display text for a record ' \
                  'or set the text_attribute option.')
          end

          ->(record) { record.send(text_attribute) }
        end
      end

      def extract_filter_option(options)
        options.fetch(:filter) do
          text_attribute = options.fetch(:text_attribute) do
            raise('Missing option: filter or text_attribute. ' \
                  'Either pass a proc which filters the scope according to a given ' \
                  'or set the text_attribute option to apply a default Ransack filter.')
          end

          ->(term, scope) { scope.ransack("#{text_attribute}_cont" => term).result }
        end
      end
    end
  end
end
