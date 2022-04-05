module ActiveAdminHelpers
  module_function

  def reload_routes!
    Rails.application.reload_routes!
  end

  def setup
    ActiveAdmin.application = nil
    yield
    reload_routes!
  end
end
