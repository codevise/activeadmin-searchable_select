require 'activeadmin/select2/engine'
require 'activeadmin/select2/filter_select_input_extension.rb'
require 'activeadmin/inputs/filter_select2_multiple_input.rb'

ActiveAdmin::Inputs::FilterSelectInput.send :include, ActiveAdmin::Select2::Inputs::FilterSelectInputExtension
