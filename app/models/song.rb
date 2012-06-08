class Song
	include Mongoid::Document
	include Mongoid::Slug
	require "#{Rails.root}/config/apis/rdio"
	
# 	after_update :update_hash

	field :name, :type => String
	field :plays, :type => Integer, default: 0
	field :track, :type => Integer, default: 1
	field :rdio_hash, :type => Hash, default: {}
	field :spotify_hash, :type => Hash, default: {}
	field :lastfm_hash, :type => Hash, default: {}
	
	belongs_to :album
	belongs_to :album_artist, class_name: 'Artist', inverse_of: :songs
	belongs_to :featuring, class_name: 'Artist', inverse_of: :featuring_songs
	has_and_belongs_to_many :tags
	has_many :rankings, dependent: :destroy
	has_many :sources
	
  validates_presence_of :name
	
	slug :name
	
	def album_name=(album_name)
		album = Album.find_or_create_by(name: album_name, artist_id: self.album_artist._id)
		self.album = album
		self.album_artist.albums << self.album
		self.album_artist.save
		self.save
	end
	
	def album_name
		self.album.name if self.album
	end
	
	def artist_featuring
		if self.featuring
			"#{self.artist_name} featuring #{self.featuring_name}"
		else
			self.artist_name
		end
	end
	
	def artist_name=(artist_name)
		self.album_artist = Artist.find_or_create_by(name: artist_name)
		self.album_artist.albums << self.album
		self.album_artist.save
# 		self.album_artist.songs << self
# 		self.album_artist.save
		self.save
	end
	
	def artist_name
		self.album_artist.name if self.album_artist
	end		
	
	def artwork
		self.album.artwork
	end
	
	def featuring_name=(featuring_name)
		self.featuring = Artist.find_or_create_by(name: featuring_name)
		self.save
# 		self.featuring.songs << self
# 		self.featuring.save
	end
	
	def featuring_name
		n = self.featuring.name if self.featuring
		unless n == ''
			n
		else
			nil
		end
	end
	
	def playlists
		playlists = []
		self.rankings.each do |r|
			playlists << r.playlist
		end
		playlists
	end
	
	def playlist_names
		names = []
		self.playlists.each do |p|
			names << p.name
		end
		names
	end
	
	def update_hash(args={})
	# Parameters:
	# service: Symbol. The service hash to update. Defaults to all. (Optional)
	
		case args[:service]
			when :rdio
				self.rdio_hash = ServiceApi.get_track(title: self.name, artist: self.artist_name, service: :rdio)
				self.album_artist.rdio_hash = ServiceApi.get_artist(key: self.rdio_hash['artistKey'], service: :rdio)
				self.featuring.rdio_hash = ServiceApi.get_artist(name: self.featuring_name, service: :rdio) if self.featuring_name
				self.album.rdio_hash = ServiceApi.get_track(key: self.rdio_hash['albumKey'], service: :rdio)
			when :lastfm
				self.lastfm_hash = ServiceApi.get_track(title: self.name, artist: self.artist_name, service: :lastfm)
				self.album_artist.lastfm_hash = ServiceApi.get_artist(key: self.lastfm_hash['artist']['mbid'], service: :lastfm)
				self.featuring.lastfm_hash = ServiceApi.get_artist(name: self.featuring_name, service: :lastfm) if self.featuring_name
				self.album.lastfm_hash = ServiceApi.get_album(key: self.lastfm_hash['album']['mbid'], service: :lastfm)
			when :spotify
				self.spotify_hash = ServiceApi.get_track(title: self.name, artist: self.artist_name, service: :spotify)
# 				self.featuring.spotify_hash = ServiceApi.get_artist(name: self.featuring_name, service: :spotify) if self.featuring_name
# 				self.album_artist.spotify_hash = ServiceApi.get_artist(key: self.spotify_hash['artist']['uri'], service: :spotify)
# 				self.album.spotify_hash = ServiceApi.get_album(key: self.spotify_hash['album']['uri'], service: :spotify)
			else
				self.rdio_hash = ServiceApi.get_track(title: self.name, artist: self.artist_name, service: :rdio) || {}
				self.lastfm_hash = ServiceApi.get_track(title: self.name, artist: self.artist_name, service: :lastfm) || {}
				self.spotify_hash = ServiceApi.get_track(title: self.name, artist: self.artist_name, service: :spotify) || {}
				self.save
				
				self.album_artist.rdio_hash = ServiceApi.get_artist(key: self.rdio_hash['artistKey'], service: :rdio) || {}
				if self.lastfm_hash['artist']
					self.album_artist.lastfm_hash = ServiceApi.get_artist(key: self.lastfm_hash['artist']['mbid'], service: :lastfm) || {}
				else
					self.album_artist.lastfm_hash = ServiceApi.get_artist(name: self.artist_name, service: :lastfm) || {}
				end
				self.album_artist.save
				
				if self.featuring_name
					self.featuring.rdio_hash = ServiceApi.get_artist(name: self.featuring_name, service: :rdio) || {}
					self.featuring.lastfm_hash = ServiceApi.get_artist(name: self.featuring_name, service: :lastfm) || {}
					self.featuring.save
				end
				
				album_rdio_hash = ServiceApi.get_album(key: self.rdio_hash['albumKey'], service: :rdio) || {}
				if self.lastfm_hash['album']
					album_lastfm_hash = ServiceApi.get_album(key: self.lastfm_hash['album']['mbid'], service: :lastfm) || {}
				else
					album_lastfm_hash = {}
				end
				if album_lastfm_hash['name']
					self.album_name = album_lastfm_hash['name']
				elsif rdio_hash['album']
					self.album_name = rdio_hash['album']
				else
					self.album_name = self.name
				end
				self.album.rdio_hash = album_rdio_hash
				self.album.lastfm_hash = album_lastfm_hash
				self.album.save
# 				self.album_artist.spotify_hash = ServiceApi.get_artist(key: self.spotify_hash['artist']['uri'], service: :spotify)
# 				self.album.spotify_hash = ServiceApi.get_album(key: self.spotify_hash['album']['uri'], service: :spotify)
		end
	end

	def tag_names=(tags_list)
		tags = tags_list.split(',')
		tags.each do |tag|
			tag.strip!
			tag.downcase!
			tag = Tag.find_or_create_by(name: tag)
			self.tags << tag unless self.tags.include?(tag)
		end
	end
	
	def tag_names
		list = []
		self.tags.each do |tag|
			list << tag.name
		end
		list.join(', ')
	end
	
	def year=(yr)
		self.album.update_attributes(year: yr)
	end
	
	def year
		self.album.year if self.album
	end
	
end
