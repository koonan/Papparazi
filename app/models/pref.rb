class Pref
  include Mongoid::Document
  include Mongoid::Geospatial

  # type
  field :preftype ,type: String

  # celebrity name
  field :name, type: String
  field :url, type: String

  # location attributes
  field :address, type: String
  field :city, type: String
  field :country ,type: String
  field :longitude, type: Float
  field :latitude, type: Float

  field :loc, :type => Array
  index({ loc: 1 }, { unique: true, background: true })

  embedded_in :user
  #embedded_in :post

end
