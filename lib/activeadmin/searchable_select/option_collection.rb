module ActiveAdmin
  module SearchableSelect
    # @api private
    class OptionCollection
      def initialize(name, options)
        @name = name

        @scope = options.fetch(:scope) do
          raise('Missing option: scope. ' \
                'Pass the collection of items to render options for.')
        end

        @text_method = options.fetch(:text_method) do
          raise('Missing option: text_method. ' \
                'Pass the name of a method which returns a display name.')
        end
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

      def text(record)
        record.send(@text_method)
      end

      def collection_action_name
        "#{@name}_options"
      end

      def as_json(template, params)
        results = records(template, params).map do |record|
          {
            id: record.id,
            text: text(record)
          }
        end

        { results: results }
      end

      private

      def records(template, params)
        limit(filter(scope(template, params), params[:term]), params[:limit])
      end

      def filter(scope, term)
        term ? scope.ransack("#{@text_method}_cont" => term).result : scope
      end

      def limit(scope, count)
        scope.limit(count || 10)
      end
    end
  end
end
