require 'activeadmin/select2/engine'
require 'activeadmin/select2/option_collection'
require 'activeadmin/select2/resource_extension'
require 'activeadmin/select2/resource_dsl_extension'
require 'activeadmin/select2/select_input_extension'
require 'activeadmin/select2/version'

ActiveAdmin::Resource.send :include, ActiveAdmin::Select2::ResourceExtension
ActiveAdmin::ResourceDSL.send :include, ActiveAdmin::Select2::ResourceDSLExtension

module ActiveAdmin
  # Global settings for searchable selects
  module Select2
    # Statically render all options into searchable selects with
    # `ajax` option set to true. This can be used to ease ui driven
    # integration testing.
    mattr_accessor :inline_ajax_options
    self.inline_ajax_options = false
  end
end
