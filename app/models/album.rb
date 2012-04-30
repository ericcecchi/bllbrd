class Album
  include Mongoid::Document
  include Mongoid::Slug
  
  field :name, :type => String
  field :year, :type => String
  field :description, :type => String
  belongs_to :artist
  has_many :songs, :dependent => :destroy

	slug :name
  
  def artist_name
  	self.artist.name if self.artist
  end
end
