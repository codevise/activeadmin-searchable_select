RSpec.configure do |config|
  config.before(:each) do
    ActiveAdmin::SearchableSelect.inline_ajax_options = false
  end
end
