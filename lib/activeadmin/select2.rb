require 'activeadmin/select2/engine'
require 'activeadmin/select2/option_collection'
require 'activeadmin/select2/resource_extension'
require 'activeadmin/select2/resource_dsl_extension'
require 'activeadmin/select2/version'

ActiveAdmin::Resource.send :include, ActiveAdmin::Select2::ResourceExtension
ActiveAdmin::ResourceDSL.send :include, ActiveAdmin::Select2::ResourceDSLExtension
