class ApplicationController < ActionController::Base

  USERS = { ENV["USER_NAME"] => ENV["PASSWORD"]}

  #before_action :basic_authentication
  before_action :digest_auth, if: :login_before?
  before_action :authenticate_user!, except: [:top]

  def after_sign_in_path_for(resource)
  days_path
  end

  def after_sign_out_path_for(resource)
  root_path
  end

  private
  def login_before?
    (controller_name == 'sessions' && action_name == 'new')||(controller_name == 'registrations' && action_name == 'new')||(request.path == '/manager')
  end

  def digest_auth
    authenticate_or_request_with_http_digest do |user|
      USERS[user]
    end
  end
end