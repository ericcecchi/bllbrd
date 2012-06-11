class Artist
  include Mongoid::Document
  include Mongoid::Slug
  include Mongoid::FullTextSearch
  
  field :name, type: String
  field :rdio_hash, type: Hash, default: {}
  field :spotify_hash, type: Hash, default: {}
  field :lastfm_hash, type: Hash, default: {}
    
  has_many :albums, dependent: :destroy
  has_many :songs, inverse_of: :album_artist, dependent: :destroy
  has_many :featuring_songs, class_name: 'Song', inverse_of: :featuring, dependent: :destroy
  
	validates_presence_of :name
  
  slug :name
  fulltext_search_in :name, max_ngrams_to_search: 1
  
  def artwork
  	if self.lastfm_hash['image']
	  	self.lastfm_hash['image'][-2]
	  else
	  	self.rdio_hash['icon']
	  end 
  end
  
  def description
  	if self.lastfm_hash['bio']['summary']
	  	des = self.lastfm_hash['bio']['summary']['#cdata-section'] || self.lastfm_hash['bio']['summary'] || ''
	  	des.html_safe
	  end
	end
end
