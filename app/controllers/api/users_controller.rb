class Api::UsersController < Api::BaseController

 def register
   user = User.create_user(params)
   if user.present?
      log_in user
      result =  {:message => 'user created', :u_id => user.id, :location => user.location }
      respond_with_success (result)
    else
      result =  {:message => 'Error'}
      respond_with_error (result)
    end
  end


  def login
    user = User.signin (params)
    if user.present?
      log_in user
      user_prefs = []
      if user.prefs.present?
        user_prefs = compose_prefs (user.prefs)
      end
      result =
       {
         :user =>
          {:u_id  => user.id, :name  => user.name, :prefs => user_prefs},
         :token =>
          {:Token => "", :validity => ""}
       }
       respond_with_success(result)
    else
        result = {:message => 'incorrect email or password'}
        respond_with_not_found(result)
    end
  end

  def edit_profile
    if current_user.update_attributes(updated_params)
      result =  {:message => 'profile updated'}
      respond_with_success(result)
    else
      result =  {:message => 'Error'}
      respond_with_error(result)
    end
  end

  def show_profile
    user_posts = []
    if current_user.posts.present?
      current_user.posts.each do |post|
        id =  post["id"]
        p = Post.find(id)
        if p.present?
          user_posts.push(p.as_json.except("user_id", "ID", "cele_id",
                                             "hashtag", "image",
                                              "point", "location_details"))
        end
      end
    end
    result = {
      :user => {
        :u_id => current_user.id,
        :name => current_user.name,
        :current_location => current_user.location,
        :attachment => current_user.attachment
      },
      :posts => user_posts,
      :prefs => compose_prefs(current_user.prefs)
    }
    respond_with_success(result)
  end


  def get_prefs
  	user_prefs = compose_prefs(current_user.prefs)
    result =
    {
   		:prefs => user_prefs
    }
    respond_with_success(result)
    result = {:message => 'Error'}
  end

  def edit_prefs
    if params[:operation][:type] == "add"
      pref = current_user.prefs.build(pref_params)
      if pref.preftype == "celebrity"
        graph = Koala::Facebook::API.new("163238854251637|13f5d496d3f7e44c6b5a14be748c4964")
        cele = graph.search(pref.name, type: :page).first
        pref.name = cele["name"]
        pref.url = cele["id"]
        if pref.save
          result = {:prefs => compose_prefs(current_user.prefs)}
          respond_with_success (result)
        else
          result = {:message => "Error"}
          respond_with_error (result)
        end
      elsif pref.preftype == "location"
        if pref.longitude.present? && pref.latitude.present?
          latitude = pref.latitude
          longitude = pref.longitude
          l =[latitude ,longitude]
          geo_localization = "#{latitude},#{longitude}"
          query = Geocoder.search(geo_localization).first
          pref.loc = l
          pref.city = query.city
          pref.country = query.country
          pref.address = query.address
          if pref.save
            result = {:prefs => compose_prefs(current_user.prefs)}
            respond_with_success (result)
          else
            result = {:message => "Error"}
            respond_with_error (result)
          end
        else
          arr = Geocoder.coordinates(pref.address)
          latitude =  arr[0]
          longitude = arr[1]
          l =[latitude ,longitude]
          pref.loc = l
          pref.latitude = latitude
          pref.longitude = longitude
          pref.loc = l
          if pref.save
            result = {:prefs => compose_prefs(current_user.prefs)}
            respond_with_success (result)
          else
            result = {:message => "Error"}
            respond_with_error (result)
          end
        end
      end
    elsif params[:operation][:type] == "remove"
      id = params[:operation][:pref][:pref_id]
      pref = current_user.prefs.find(id)
      pref.destroy
      if pref.destroyed?
        result = {:prefs => compose_prefs(current_user.prefs)}
        respond_with_success (result)
      else
        result = {:message => "Error"}
        respond_with_error (result)
      end
    end
  end


  def follow
    if params[:operation][:type] == "follow"
      following_rel = current_user.relationships.build
      following_rel.following_id = params[:operation][:u_id]
      if following_rel.save
        following_user = User.find(params[:operation][:u_id])
        follower_rel = following_user.relationships.build
        follower_rel.follower_id = current_user.id
        if follower_rel.save
          following_users = get_following_users (current_user.relationships)
          result = {
            "following_users" => following_users
          }
          respond_with_success (result)
        else
          result = {:message => "Error"}
          respond_with_error (result)
        end
      else
        result = {:message => "Error"}
        respond_with_error (result)
      end
    elsif params[:operation][:type] == "unfollow"
      id = params[:operation][:u_id]
      following_rel = current_user.relationships.find_by following_id: id
      following_user = User.find(params[:operation][:u_id])
      id = current_user.id
      follower_rel = following_user.relationships.find_by follower_id: id
      following_rel.destroy
      follower_rel.destroy
      if following_rel.destroyed? && follower_rel.destroyed?
        following_users = get_following_users (current_user.relationships)
        result = {
          "following_users" => following_users
        }
        respond_with_success (result)
      else
        result = {:message => "Error"}
        respond_with_error (result)
      end
    end
  end

  def get_followers
    users = get_user_followers (current_user.relationships)
    result = {
      "followers" => users
    }
    respond_with_success (result)
  end

  def get_following
    users = get_following_users (current_user.relationships)
    result = {
      "following" => users
    }
    respond_with_success (result)
  end


  private
   def updated_params
       params.require(:user).permit(:name, :date_of_birth, :attachment)
   end

   def pref_params
      params[:operation].require(:pref).permit(:name, :address,
                                            :longitude, :latitude, :preftype)
   end

   def compose_prefs (prefs)
     user_prefs = []
     prefs.each do |pref|
       user_prefs.push(pref.as_json.except("loc"))
     end
     return user_prefs
   end

   def get_following_users (relationships)
     users = []
     relationships.each do |rel|
      if rel.following_id.present?
        user = User.find(rel.following_id)
        new_user = {
          :u_id => user.id,
          :name => user.name,
          :email => user.email,
          :attachment => user.attachment
        }
        users.push (new_user)
      end
     end
     return users
  end

   def get_user_followers (relationships)
     users = []
     relationships.each do |rel|
      if rel.follower_id.present?
        user = User.find(rel.follower_id)
        new_user = {
          :u_id => user.id,
          :name => user.name,
          :email => user.email,
          :attachment => user.attachment
        }
        users.push (new_user)
      end
     end
     return users
   end
end
