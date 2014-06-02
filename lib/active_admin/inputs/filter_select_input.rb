module ActiveAdmin
  module Inputs

    class FilterMultipleSelectInput < Formtastic::Inputs::SelectInput
      def extra_input_html_options
        {
          :class => 'select2-input',
          :multiple => true
        }
      end
    end

    class FilterSelectInput < ::Formtastic::Inputs::SelectInput
      def extra_input_html_options
        {
          :class => 'select2-input'
        }
      end
    end

  end
end
