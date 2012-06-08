class Playlist
  include Mongoid::Document
  include Mongoid::Slug

  field :name, :type => String
  field :description, :type => String
  has_many :rankings, dependent: :destroys
    
  slug :name
end
