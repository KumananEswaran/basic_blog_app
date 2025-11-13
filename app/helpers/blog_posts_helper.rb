module BlogPostsHelper
    def excerpt_for(post, length = 200)
    return "" unless post.present?

    if post.respond_to?(:body) && post.body.respond_to?(:to_plain_text)
      truncate(post.body.to_plain_text, length: length)
    else
      truncate(post.body.to_s, length: length)
    end
  end
end
