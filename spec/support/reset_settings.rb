RSpec.configure do |config|
  config.before(:each) do
    ActiveAdmin::Select2.inline_ajax_options = false
  end
end
