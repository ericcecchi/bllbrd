class User
  include Mongoid::Document
  field :provider, :type => String
  field :uid, :type => String
  field :nickname, :type => String
  
  def self.create_with_omniauth(auth)
	  create! do |user|
	    user.provider = auth["provider"]
	    user.uid = auth["uid"]
	    user.nickname = auth["info"]["nickname"]
	  end
	end
end
