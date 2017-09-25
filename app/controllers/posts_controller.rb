class PostsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    @post = Post.new(all_post_params)
    current_post = @post
    @location = current_post.prefs.build(loc_params)

    if @post.save

      if !(@location.longitude == nil || @location.latitude == nil)
        latitude = @location.latitude
        longitude =@location.longitude
        l =[longitude ,latitude]

        @location.loc = l

        geo_localization = "#{latitude},#{longitude}"
        query = Geocoder.search(geo_localization).first
        add = query.address

        @location.city = query.city
        @location.country = query.country
        #  puts "city  " + query.city.to_s
        #  puts "country " + query.country.to_s

        @location.address = add
        @location.save
      else
        arr =Geocoder.coordinates(@location.address)
        latitude =  arr[0]
        longitude = arr[1]
        l =[longitude ,latitude]

        @location.loc = l


        @location.latitude = latitude
        @location.longitude = longitude

        geo_localization = "#{latitude},#{longitude}"
        query = Geocoder.search(geo_localization).first
        add = query.address

        @location.city = query.city
        @location.country = query.country
        @location.save

      end

      if @location.save
        render 'static_pages/success'
      else
        render 'static_pages/fail'
      end
      info = Hash.new
      info["type"] = "Point"
      info["coordinates"] = @location.loc
      @post.point = info
      @post.save

      extract_tag(@post.content , @post.id)

      post = Hash.new
      post[:id] = @post.id.to_s


      if (current_user.posts == nil)
      current_user.posts =  [post]
      else
        current_user.posts << post
      end
      current_user.save
      puts "----------------" + current_user.posts.to_s

      #before update
    #  @post = current_user.posts.build(postid: @post.id)

      # @post.save

       #Important find nearest location
       puts "start"

    #  item = Post.geo_near([31,30]).spherical.max_distance(170.fdiv(6371)).as_json
    #  item.each { |x|  puts "-------------cccccccccccccccccccc" + x["content"].to_s  }
      puts"end"

    end
end


def destroy
end

private

def all_post_params
params.require(:post).permit(:content)
end


def loc_params
params.require(:pref).permit(:address ,:longitude,:latitude)
end


def extract_tag (content,id)
names = content.scan(/#\w+/).flatten
names.each { |item|
 item.gsub("#","")
 item.gsub("_"," ")
 item.tr('#', '')

   current_tag = Tag.find_by(name: item)
   if (current_tag == nil)
     current_tag = Tag.new(name: item)
     @graph = Koala::Facebook::API.new("EAACEdEose0cBABLPRW84pTBIMSK9w98CZB5rAvKIguX7F6wswEqFACMBWUwGN9GihLY1cmkculMVg1Ndjv6xHC2SGZCP5aEZC6DCmxCu7Cpx1eMqrFa9HrkOYqii6yTz6nbbcZAWgxlZBZAJtHzoPT4qVLgZCkYZAMHpiNUDxlZCnPwedZBoNDjndPToLdUkPTybgZD")
     cele = @graph.search(item, type: :page).first
     current_tag.cel = cele ["name"]
     current_tag.url = cele ["id"]

     
    end
   if current_tag.save
   end


   post = Hash.new
   post[:id] = id.to_s

   if (current_tag.posts == nil)
   current_tag.posts =  [post]
   else
     current_tag.posts << post
   end
   current_tag.save

   #before update
#  @post = current_tag.posts.build(postid: id)
#  if @post.save
#  end
}
end

end
