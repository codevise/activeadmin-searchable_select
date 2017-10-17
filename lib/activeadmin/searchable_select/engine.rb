require 'active_admin'
require 'select2-rails'

module ActiveAdmin
  module SearchableSelect
    # @api private
    class Engine < ::Rails::Engine
      engine_name 'activeadmin_searchable_select'
    end
  end
end
