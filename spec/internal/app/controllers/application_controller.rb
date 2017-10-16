class ApplicationController < ActionController::Base
  cattr_accessor :current_user

  helper_method :current_user
end
