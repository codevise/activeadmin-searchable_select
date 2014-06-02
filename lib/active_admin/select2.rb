require 'active_admin/select2/engine'
require 'active_admin/select2/filter_select_input_extension.rb'
require 'active_admin/inputs/filter_multiple_select_input.rb'

ActiveAdmin::Inputs::FilterSelectInput.send :include, ActiveAdmin::Select2::Inputs::FilterSelectInputExtension
