module ActiveAdmin
  module Inputs
    class FilterSelect2MultipleInput < Formtastic::Inputs::SelectInput

     include FilterBase

     def input_name
        "#{super}_in"
      end

      def extra_input_html_options
        {
          :class => 'select2-input', :multiple => true
        }
      end

    end
  end
end
