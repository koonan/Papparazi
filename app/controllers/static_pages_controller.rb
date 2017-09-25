class StaticPagesController < ApplicationController
    def home
      if logged_in?
      @all_posts = Post.all
      @post = Post.new
      current_post = @post
      @location = current_post.prefs.build
    #  @post = current_user.posts.build

      @feed_items = current_user.posts

      @relationships = current_user.relationships.build
      @friends_feeds = current_user.relationships
      @cel_prefs =    current_user.prefs
      @loc_prefs =    current_user.prefs
    end

  end
end
