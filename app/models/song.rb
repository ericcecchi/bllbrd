class Song
  include Mongoid::Document
  include Mongoid::Slug

  field :name, :type => String
  field :plays, :type => Integer, default: 0
  field :billboard_ranking, :type => Integer, default: 0
  belongs_to :album
  has_and_belongs_to_many :tags
  has_and_belongs_to_many :playlists
  has_many :sources
  
	slug :name
	
	def album_name=(album_name)
		album = Album.find_or_create_by(name: album_name)
		self.album = album
		self.save
	end
	
	def album_name
		self.album.name if self.album
	end
	
	def artist_name=(artist_name)
		artist = Artist.find_or_create_by(name: artist_name)
		artist.albums << self.album
		artist.save
	end
	
	def artist_name
		self.album.artist.name if self.album and self.album.artist
	end
	
	def tag_names=(tags_list)
		self.tags = []
		tags = tags_list.split(',')
		tags.each do |tag|
			tag.strip!
			tag.downcase!
			tag = Tag.find_or_create_by(name: tag)
			self.tags << tag
		end
		self.save
	end
	
	def tag_names
		self.tag_ids.sort.join(', ').humanize.downcase
	end
	
	def year=(yr)
		self.album.year = yr
		self.album.save
	end
	
	def year
		self.album.year if self.album
	end
end
