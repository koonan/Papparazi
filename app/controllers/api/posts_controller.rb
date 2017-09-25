class Api::PostsController < Api::BaseController

  def find_post
    post = Post.get_post(params[:id])
    if post.present?
      respond_with_success (post.as_json.except("user_id", "ID", "cele_id",
                                      "hashtag", "image", "prefs",
                                      "point", "location_details"))
    else
      result = {:message => "Error"}
      respond_with_error (result)
    end
  end


  def remove_post
    if Post.destroy_post (params[:id])
      result = {
        :message => "post is destroyed successfully"
      }
      respond_with_success (result)
    else
      result = {:message => "Error"}
      respond_with_error (result)
    end
  end


  def set_home_locaiton
    if params[:location][:latitude].present? && params[:location][:longitude].present?
      latitude = params[:location][:latitude]
      longitude = params[:location][:longitude]
      geo_localization = "#{latitude},#{longitude}"
      query = Geocoder.search(geo_localization).first
      current_user.location = {
        :address => query.address,
        :country => query.country,
        :city => query.city,
        :longitude => params[:location][:longitude],
        :latitude => params[:location][:latitude]
      }
      current_user.save
      result = {
        :message => "home location updated"
      }
      respond_with_success (result)
    else
        result = {
          :message => "Error"
        }
      respond_with_error(result)
    end
  end



  def add_post
    post = Post.create_post (params)
    post.user_info = {
      :id => current_user.id,
      :name => current_user.name,
      :index => current_user.posts.size
    }
    extract_tag(post)
    if !current_user.posts.present?
      current_user.posts = []
    end
    current_user.posts.push({:id => post.id})
    current_user.save
    if post.save
     result = {
          :message => "post created",
          :post_id => post.id
        }
        respond_with_success (result)
    else
      result = {
        :message => "Error"
      }
      respond_with_error (result)
    end
  end



  def feed
    posts = []

    # friends
    current_user.relationships.each do |rel|
      if rel.following_id.present?
         user = User.get_user(rel.following_id)
         if user.present?
           posts += construct_posts(user.posts)
         end
       end
    end

    # prefs
    current_user.prefs.each do |pref|
        if pref.preftype == "celebrity"
            tag = Tag.find_by cel: pref.name
            if tag.present?
              posts +=  construct_posts (tag.posts)
            end
        elsif pref.preftype == "location"
          items = Post.geo_near([pref.latitude,pref.longitude]).spherical.max_distance(5.fdiv(6371)).as_json
          items.each do |post|
            posts.push(post.as_json.except("user_id", "ID", "cele_id",
                                            "hashtag", "image",
                                            "point", "location_details"))
          end
        end
    end

    # current_location
    items = Post.geo_near([current_user.location[:latitude],current_user.location[:longitude]]).spherical.max_distance(5.fdiv(6371)).as_json
    items.each do |post|
      posts.push(post.as_json.except("user_id", "ID", "cele_id",
                                      "hashtag", "image",
                                      "point", "location_details"))
    end

    result = {
      :posts => posts
    }
    respond_with_success(result)
  end

  private

  def extract_tag (post)
    post.keywords.each { |item|
      item.gsub("#","")
      item.gsub("_"," ")
      item.tr('#', '')
      current_tag = Tag.find_by(name: item)
      if (!current_tag.present?)
         current_tag = Tag.new(name: item)
         graph = Koala::Facebook::API.new("163238854251637|13f5d496d3f7e44c6b5a14be748c4964")
         cele = graph.search(item, type: :page).first
         current_tag.cel = cele ["name"]
         current_tag.url = cele ["id"]
      end
      if !post.celebrityTags.present?
        post.celebrityTags = []
      end
      post.celebrityTags.push({:name => current_tag.cel, :url => current_tag.url})

      if !post.tags.present?
        post.tags = []
      end
      post.tags.push ({:id => current_tag.id, :index => current_tag.posts.size})

      p = Hash.new
      p[:id] = post.id
      if (!current_tag.posts.present?)
        current_tag.posts =  [p]
      else
        current_tag.posts << p
      end
      current_tag.save
    }
  end
end

def construct_posts(posts)
  all_posts = []
  if posts.present?
    posts.each do |post|
      p = Post.get_post(post["id"])
      if p.present?
        all_posts.push(p.as_json.except("user_id", "ID", "cele_id",
                                        "hashtag", "image",
                                        "point", "location_details"))
      end
    end
  end
  return all_posts
end
