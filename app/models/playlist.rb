class Playlist
  include Mongoid::Document
  include Mongoid::Slug

  field :name, :type => String
  field :description, :type => String
  has_and_belongs_to_many :songs
    
  slug :name
end
