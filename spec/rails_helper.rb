ENV['RAILS_ENV'] ||= 'test'

require 'logger'
require 'combustion'
Combustion.initialize!(:active_record, :action_controller, :action_view, :sprockets)

if Rails.version >= '7.1'
  Rails.application.config.action_dispatch.show_exceptions = :none
else
  Rails.application.config.action_dispatch.show_exceptions = false
end

require 'rspec/rails'
require 'support/reset_settings'

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!
end
