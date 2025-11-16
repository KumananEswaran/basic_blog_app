class BlogPostsController < ApplicationController
  # require login for actions that view or change posts
  before_action :authenticate_user!, only: %i[index show new create edit update destroy]

  # load the post before actions that need it
  before_action :set_blog_post, only: %i[show edit update destroy]

  # ensure only the owner may edit/update/destroy
  before_action :authorize_user!, only: %i[edit update destroy]

  # GET /blog_posts
  def index
    if params[:mine].present? && user_signed_in?
      @blog_posts = current_user.blog_posts.order(created_at: :desc)
    elsif params[:user_id].present?
      user = User.find_by(id: params[:user_id])
      @blog_posts = user ? user.blog_posts.order(created_at: :desc) : BlogPost.none
    else
      @blog_posts = BlogPost.order(created_at: :desc).page(params[:page]).per(8)
    end
  end

  # GET /my_posts
  def my_posts
    unless user_signed_in?
      redirect_to new_user_session_path, alert: "You must sign in to view your posts."
      return
    end

    @blog_posts = current_user.blog_posts.order(created_at: :desc).page(params[:page]).per(8)
    render :index
  end

  # GET /blog_posts/:id
  def show
  end

  # GET /blog_posts/new
  def new
    @blog_post = BlogPost.new
  end

  # POST /blog_posts
  def create
    @blog_post = current_user.blog_posts.build(blog_post_params)
    if @blog_post.save
      redirect_to @blog_post, notice: "Post was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /blog_posts/:id/edit
  def edit
  end

  # PATCH/PUT /blog_posts/:id
  def update
    respond_to do |format|
      if @blog_post.update(blog_post_params)
        format.html { redirect_to @blog_post, notice: "Blog post was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @blog_post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @blog_post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /blog_posts/:id
  def destroy
    @blog_post.destroy!

    respond_to do |format|
      format.html { redirect_to blog_posts_path, notice: "Blog post was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_blog_post
    @blog_post = BlogPost.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def blog_post_params
    params.require(:blog_post).permit(
      :title,
      :body,
      :meta_description,
      :meta_title,
      :mrta_image,
      :banner_image,
      tags: []
    )
  end

  def authorize_user!
    # If you have admins who should bypass this, change condition to:
    # unless @blog_post.user == current_user || (current_user.respond_to?(:admin?) && current_user.admin?)
    unless @blog_post.user == current_user
      respond_to do |format|
        format.html { redirect_to blog_posts_path, alert: "You are not authorized to perform this action." }
        format.json { head :forbidden }
      end
    end
  end
end