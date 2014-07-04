module Formtastic
  module Inputs

    class Select2MultipleInput < Formtastic::Inputs::SelectInput
      def extra_input_html_options
        {
          :class => 'select2-input', :multiple => true
        }
      end
    end

  end
end
