class User

  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include ActiveModel::SecurePassword
  before_save {self.email =email.downcase}
  field :name, type: String
  field :email, type: String
  field :password_digest ,type: String
  field :posts , :type => Array
  field :attachment, type: String
  field :date_of_birth, type: Date
  field :location, type: Hash
  validates_presence_of :name, :email
  embeds_many :relationships
  embeds_many :prefs
  has_secure_password

  def self.get_user (id)
    user = User.find(id)
    return user
  end

  def self.following?(other_user)
    Relationship.find(:id).present?
  end

  def self.create_user (parameters)
    user = User.find_by(email: parameters[:user][:email].downcase)
    if !user.present?
      user = User.new(user_params(parameters))
      if user.save
         return user
      else
        return nil
      end
    else
      return nil
    end
  end

  def self.signin (params)
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      return user
    else
      return nil
    end
  end

  def self.signout
    log_out if logged_in?
  end

  def self.user_params (params)
   params.require(:user).permit(:name, :email, :password,
   :password_confirmation, :date_of_birth, :posts => [] ,:location => {})
  end


end
