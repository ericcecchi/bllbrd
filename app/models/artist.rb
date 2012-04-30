class Artist
  include Mongoid::Document
  include Mongoid::Slug
  
  field :name, :type => String
  field :description, :type => String
  has_many :albums, :dependent => :destroy
    
  slug :name
end
