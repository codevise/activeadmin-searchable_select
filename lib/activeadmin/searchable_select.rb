require 'activeadmin/searchable_select/engine'
require 'activeadmin/searchable_select/option_collection'
require 'activeadmin/searchable_select/resource_extension'
require 'activeadmin/searchable_select/resource_dsl_extension'
require 'activeadmin/searchable_select/select_input_extension'
require 'activeadmin/searchable_select/version'

ActiveAdmin::Resource.send :include, ActiveAdmin::SearchableSelect::ResourceExtension
ActiveAdmin::ResourceDSL.send :include, ActiveAdmin::SearchableSelect::ResourceDSLExtension

module ActiveAdmin
  # Global settings for searchable selects
  module SearchableSelect
    # Statically render all options into searchable selects with
    # `ajax` option set to true. This can be used to ease ui driven
    # integration testing.
    mattr_accessor :inline_ajax_options
    self.inline_ajax_options = false
  end
end
