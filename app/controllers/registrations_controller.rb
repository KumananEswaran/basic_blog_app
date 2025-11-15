class RegistrationsController < Devise::RegistrationsController
  protected

  def sign_up(resource_name, resource)
  end

  def after_sign_up_path_for(resource)
    new_user_session_path
  end

  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end

  def update_resource(resource, params)
    if params[:password].blank? && params[:password_confirmation].blank? && params[:current_password].blank?
      resource.update_without_password(params.except(:current_password))
    else
      super
    end
  end

  def after_update_path_for(resource)
    blog_posts_path
  end

  public

  def create
    super
    if resource.persisted?
      flash[:notice] = 'Account created. Please sign in.'
    end
  end
end