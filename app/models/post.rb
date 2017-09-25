class Post

  extend SessionsHelper
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  field :user_id, type: Object
  field :ID, type: String
  field :cele_id, type: Object
  field :hashtag, type: String
  field :image, type: String
  field :point, type: Hash
# formal attributes
  field :keywords, type: Array # array of strings
  field :content, type: String
  field :attachments, type: Array # array of strings
  field :location, type: Hash
  field :created_at, type: String
  field :celebrityTags, type: Array
  field :user_info, type: Hash
  field :tags, type: Array
  field :location_details, type: Hash
  index({point: "2dsphere"})

  #index({ loc: 1 }, { unique: true, background: true })
  #embeds_many :prefs
  #  index(
  #       [
  #           [:loc, Mongo::GEO2D]
  #       ], background: true
  #   )
  #  validates_presence_of :address, :unless => :longitude?
  #  validates_presence_of :longitude, :unless => :address?
  #  validates_presence_of :latitude, :unless => :address?

  def self.get_post (id)
    post = Post.find(id)
    return post
  end

  def self.destroy_post(id)
    post = Post.find(id)
    if post.present?
      user = User.find(post.user_info[:id])
      user.posts.delete_at(post.user_info[:index])
      post.tags.each do |t|
        tag = Tag.find(t[:id])
        tag.posts.delete_at(t[:index])
      end
      post.destroy
      return post.destroyed?
    end
    return false
  end

  def self.create_post (parameters)
    post = Post.new(post_params(parameters))
    location = []
    if (post.location[:longitude]).present? && (post.location[:latitude]).present?
      latitude  = post.location[:latitude]
      longitude = post.location[:longitude]
      location = [longitude ,latitude]
      geo_localization = "#{latitude},#{longitude}"
      query = Geocoder.search(geo_localization).first
      post.location_details = query.as_json
    else
      arr = Geocoder.coordinates(post.location[:address])
      latitude =  arr[0]
      longitude = arr[1]
      location = [longitude ,latitude]
      geo_localization = "#{latitude},#{longitude}"
      query = Geocoder.search(geo_localization).first
      post.location_details = query.as_json
    end
    info = Hash.new
    info["type"] = "Point"
    info["coordinates"] = location
    post.point = info
    post.created_at = Time.now.strftime("%m/%d/%Y")
    return post
  end

  def self.post_params(params)
   params.require(:post).permit(:content, :location => {}, :keywords => [], :attachments => [])
  end

end
