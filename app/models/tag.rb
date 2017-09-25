class Tag
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  field :name, type: String
  field :cel, type: String
  field :url, type: String
  field :posts , :type => Array
#  embeds_many :posts
end
