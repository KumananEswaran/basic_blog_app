class Users::RegistrationsController < Devise::RegistrationsController
  protected

  # Prevent Devise from automatically signing in the user after sign up.
  def sign_up(resource_name, resource)
    # no-op: do not call sign_in(resource_name, resource)
  end

  # Redirect new users to the login page after successful registration
  def after_sign_up_path_for(resource)
    new_user_session_path
  end

  # Also redirect inactive signups (e.g. confirmable) to the login page
  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end

  # Optional: add a flash message so users know to sign in
  def create
    super
    if resource.persisted?
      flash[:notice] = 'Account created. Please sign in.'
    end
  end
end