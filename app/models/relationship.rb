class Relationship
  include Mongoid::Document
  field :following_id, type: BSON::ObjectId
  field :follower_id, type: BSON::ObjectId
  embedded_in :user
end
