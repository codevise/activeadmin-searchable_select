module ActiveAdmin
  module Select2
    module Inputs
      module FilterSelectInputExtension

        def extra_input_html_options
          {
            :class => 'select2-input'
          }
        end

      end
    end
  end
end
