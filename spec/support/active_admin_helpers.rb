module ActiveAdminHelpers
  module_function

  def setup
    ActiveAdmin.application = nil
    yield
    Rails.application.reload_routes!
  end
end
