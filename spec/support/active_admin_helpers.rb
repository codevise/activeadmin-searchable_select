module ActiveAdminHelpers
  module_function

  def setup
    ActiveAdmin.unload!
    yield
    Rails.application.reload_routes!
  end
end
