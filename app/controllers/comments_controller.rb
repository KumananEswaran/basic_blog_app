class CommentsController < ApplicationController
  before_action :set_blog_post
  before_action :set_comment, only: [:edit, :update, :destroy]
  before_action :authenticate_user!, only: [:edit, :update, :destroy]
  before_action :authorize_user!, only: [:edit, :update, :destroy]

  def create
    @comment = @blog_post.comments.build(comment_params)
    if user_signed_in?
      @comment.user = current_user
      @comment.name = current_user.username if @comment.name.blank?
    end

    if @comment.save
      redirect_to blog_post_path(@blog_post), notice: "Comment posted."
    else
      @comments = @blog_post.comments.order(created_at: :asc)
      flash.now[:alert] = "Unable to post comment."
      render "blog_posts/show", status: :unprocessable_entity
    end
  end

  def edit
    # renders edit template
  end

  def update
    if @comment.update(comment_params)
      redirect_to blog_post_path(@blog_post), notice: "Comment updated."
    else
      flash.now[:alert] = "Unable to update comment."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @comment.destroy
    redirect_to blog_post_path(@blog_post), notice: "Comment deleted."
  end

  private

  def set_blog_post
    @blog_post = BlogPost.find(params[:blog_post_id])
  end

  def set_comment
    @comment = @blog_post.comments.find(params[:id])
  end

  def authorize_user!
    unless @comment.user == current_user
      redirect_to blog_post_path(@blog_post), alert: "Not authorized."
    end
  end

  def comment_params
    params.require(:comment).permit(:name, :body)
  end
end
