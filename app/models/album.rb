class Album
  include Mongoid::Document
  include Mongoid::Slug
  
  field :name, type: String, default: ''
  field :rdio_hash, type: Hash, default: {}
  field :spotify_hash, type: Hash, default: {}
  field :lastfm_hash, type: Hash, default: {}
    
  belongs_to :artist
  has_many :songs, dependent: :destroy
  
  validates_presence_of :name, message: "Album name cannot be blank."

	slug :name
	
	def artwork
		if self.lastfm_hash['image']
  		self.lastfm_hash['image'][-3]
  	elsif rdio_hash
  		self.rdio_hash['icon']
  	end
	end
	
	def description
  	if self.lastfm_hash and self.lastfm_hash['wiki']
	  	des = self.lastfm_hash['wiki']['summary']['#cdata-section'] || self.lastfm_hash['wiki']['summary']
	  	des.html_safe
	  end
	end
  
  def artist_name
  	self.artist.name if self.artist
  end
  
  def year
	  if rdio_hash['releaseDate']
  		self.rdio_hash['releaseDate'].split('-')[0]
  	end
  end
end
