class Album
  include Mongoid::Document
  include Mongoid::Slug
  
  field :name, :type => String
  field :description, :type => String
  belongs_to :artist
  has_many :songs
    
	slug :name
end
