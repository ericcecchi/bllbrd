class ServiceApi
	require "#{Rails.root}/config/apis/rdio"
	require 'open-uri'
	
	def self.get_album(args)
	# Parameters:
	#
	# :service (Symbol)
	#		The API to use for the album lookup. Currently, :rdio, :lastfm, or :spotify. (Required)
	# :name (String)
	#		Title of the album. Used for search. (Required unless given a key)
	# :artist (String)
	#		Main artist of the album. Used for search. (Optional)
	# :key (String)
	#		The unique key for the given service. (Optional)
	# :limit (Integer)
	#		If given limit > 1, it will return an array of the top results. Defaults to 1. (Optional)
	#
	# Returns an album hash or array of album hashes from the given service API.
		
		if args[:key]
			begin
				case args[:service]
					when :rdio
						# Rdio album lookup (JSON)
						rdio = Rdio.new(["jnm9ynpuwpd6u37gxwam8eup", "Gvzh3a6ZGS"])
						response = rdio.call('get', {'keys'=> args[:key]})
						album = response['result'][args[:key]] if response['status']['ok']
					when :lastfm
						# Last.fm album lookup (XML)
						uri = URI.escape("http://ws.audioscrobbler.com/2.0/?method=album.getInfo&api_key=ed76a5bbe609896ac6a75709e0252691&&mbid=#{args[:key]}")
						album = Hash.from_xml(open(uri))['lfm']['album']
				end
			rescue OpenURI::HTTPError, Errno::ECONNREFUSED, Errno::ECONNRESET
				album = ''
			end
			return album
		
		elsif (args[:name] and (args[:limit] == 1 or args[:limit].nil?))
			begin
				case args[:service]
					when :spotify
						# Spotify album search (JSON)
						uri = URI.escape("http://ws.spotify.com/search/1/album.json?q=#{args[:name].gsub("&","and").gsub(",","%20")} #{args[:name].gsub("&","and").gsub(",","%20")}")
						json = JSON.parse(open(uri).read)
						album = json['albums'][0]
					when :rdio
						# Rdio album search (JSON)
						rdio = Rdio.new(["jnm9ynpuwpd6u37gxwam8eup", "Gvzh3a6ZGS"])
						json = rdio.call('search', {'query'=>"#{args[:name]} #{args[:artist]}", 'types' => 'Album', 'count' => 1})['result']
						album = json['results'][0]
					when :lastfm
						# Last.fm album search (XML)
						uri = URI.escape("http://ws.audioscrobbler.com/2.0/?method=album.getInfo&api_key=ed76a5bbe609896ac6a75709e0252691&artist=#{args[:artist].gsub("&","and").gsub(",","%20")}&album=#{args[:name].gsub("&","and").gsub(",","%20")}&autocorrect=1")
						album = Hash.from_xml(open(uri))['lfm']['album']
				end
			rescue OpenURI::HTTPError, Errno::ECONNREFUSED, Errno::ECONNRESET
				album = ''
			end
			return album
		
		elsif (args[:name] and args[:limit] > 1)
			begin
				case args[:service]
					when :spotify
						# Spotify album search (JSON)
						uri = URI.escape("http://ws.spotify.com/search/1/album.json?q=#{args[:name].gsub("&","and").gsub(",","%20")} #{args[:name].gsub("&","and").gsub(",","%20")}")
						json = JSON.parse(open(uri).read)
						albums = json['albums'][0..args[:limit]]
					when :rdio
						# Rdio album search (JSON)
						rdio = Rdio.new(["jnm9ynpuwpd6u37gxwam8eup", "Gvzh3a6ZGS"])
						json = rdio.call('search', {'query'=>"#{args[:name]} #{args[:artist]}", 'types' => 'Album', 'count' => args[:limit]})['result']
						albums = json['results']
					when :lastfm
						# Last.fm album search (XML)
						uri = URI.escape("http://ws.audioscrobbler.com/2.0/?method=album.search&api_key=ed76a5bbe609896ac6a75709e0252691&artist=#{args[:artist].gsub("&","and").gsub(",","%20")}&album=#{args[:name].gsub("&","and").gsub(",","%20")}&limit=#{args[:limit]}")
						albums = Hash.from_xml(open(uri))['lfm']['results']['albummatches']
				end
			rescue OpenURI::HTTPError, Errno::ECONNREFUSED, Errno::ECONNRESET
				albums = ''
			end
			return albums			
		end
	end

	def self.get_artist(args)
	# Parameters:
	#
	# :service (Symbol)
	#		The API to use for the artist lookup. Currently, :rdio, :lastfm, or :spotify. (Required)
	# :name (String)
	#		The name of the artist. (Required unless given a key)
	# :key (String)
	#		The unique key for the given service. (Optional)
	# :limit (Integer)
	#		If given limit > 1, it will return an array of the top results. Defaults to 1. (Optional)
	#
	# Returns an artist hash or array of artist hashes from the given service API.
		
		if args[:key]
			begin
				case args[:service]
					when :rdio
						# Rdio artist lookup (JSON)
						rdio = Rdio.new(["jnm9ynpuwpd6u37gxwam8eup", "Gvzh3a6ZGS"])
						response = rdio.call('get', {'keys'=> args[:key]})
						artist = response['result'][args[:key]] if response['status']['ok']
					when :lastfm
						# Last.fm artist lookup (XML)
						uri = URI.escape("http://ws.audioscrobbler.com/2.0/?method=artist.getInfo&api_key=ed76a5bbe609896ac6a75709e0252691&&mbid=#{args[:key]}")
						artist = Hash.from_xml(open(uri))['lfm']['artist']
				end
			rescue OpenURI::HTTPError, Errno::ECONNREFUSED, Errno::ECONNRESET
				artist = ''
			end
			return artist
		
		elsif (args[:name] and (args[:limit] == 1 or args[:limit].nil?))
			begin
				case args[:service]
					when :spotify
						# Spotify artist search (JSON)
						uri = URI.escape("http://ws.spotify.com/search/1/artist.json?q=#{args[:name].gsub("&","and").gsub(",","%20")}")
						json = JSON.parse(open(uri).read)
						artist = json['artists'][0]
					when :rdio
						# Rdio artist search (JSON)
						rdio = Rdio.new(["jnm9ynpuwpd6u37gxwam8eup", "Gvzh3a6ZGS"])
						json = rdio.call('search', {'query'=>"#{args[:name]}", 'types' => 'Artist', 'count' => 1})['result']
						artist = json['results'][0]
					when :lastfm
						# Last.fm artist search (XML)
						uri = URI.escape("http://ws.audioscrobbler.com/2.0/?method=artist.getInfo&api_key=ed76a5bbe609896ac6a75709e0252691&artist=#{args[:name].gsub("&","and").gsub(",","%20")}&autocorrect=1")
						artist = Hash.from_xml(open(uri))['lfm']['artist']
				end
			rescue OpenURI::HTTPError, Errno::ECONNREFUSED, Errno::ECONNRESET
				artist = ''
			end
			return artist
		
		elsif (args[:name] and args[:limit] > 1)
			begin
				case args[:service]
					when :spotify
						# Spotify artist search (JSON)
						uri = URI.escape("http://ws.spotify.com/search/1/artist.json?q=#{args[:name].gsub("&","and").gsub(",","%20")}")
						json = JSON.parse(open(uri).read)
						artists = json['artists'][0..args[:limit]]
					when :rdio
						# Rdio artist search (JSON)
						rdio = Rdio.new(["jnm9ynpuwpd6u37gxwam8eup", "Gvzh3a6ZGS"])
						json = rdio.call('search', {'query'=>"#{args[:name]}", 'types' => 'Artist', 'count' => args[:limit]})['result']
						artists = json['results']
					when :lastfm
						# Last.fm artist search (XML)
						uri = URI.escape("http://ws.audioscrobbler.com/2.0/?method=artist.search&api_key=ed76a5bbe609896ac6a75709e0252691&artist=#{args[:name].gsub("&","and").gsub(",","%20")}&limit=#{args[:limit]}")
						artists = Hash.from_xml(open(uri))['lfm']['results']['artistmatches']
				end
			rescue OpenURI::HTTPError, Errno::ECONNREFUSED, Errno::ECONNRESET
				artists = ''
			end
			return artists			
		end
	end
	
	def self.get_track(args)
	# Parameters:
	#
	# :service (Symbol)
	#		The API to use for the track lookup. Currently, :rdio, :lastfm, or :spotify. (Required)
	# :title (String)
	#		Title of the song. Used for search. (Required unless given a key)
	# :artist (String)
	#		Main artist of the song. Used for search. (Optional)
	# :key (String)
	#		The unique key for the given service. (Optional)
	# :limit (Integer)
	#		If given limit > 1, it will return an array of the top results. Defaults to 1. (Optional)
	#
	# Returns a track hash or array of track hashes from the given service API.
		
		if args[:key]
			begin
				case args[:service]
					when :rdio
						# Rdio track search (JSON)
						rdio = Rdio.new(["jnm9ynpuwpd6u37gxwam8eup", "Gvzh3a6ZGS"])
						response = rdio.call('get', {'keys'=> args[:key]})
						track = response['result'][args[:key]] if response['status']['ok']
					when :lastfm
						# Last.fm track search (XML)
						uri = URI.escape("http://ws.audioscrobbler.com/2.0/?method=track.getInfo&api_key=ed76a5bbe609896ac6a75709e0252691&&mbid=#{args[:key]}")
						track = Hash.from_xml(open(uri))['lfm']['track']
				end
			rescue OpenURI::HTTPError, Errno::ECONNREFUSED, Errno::ECONNRESET
				track = ''
			end
			return track
		
		elsif (args[:title] and (args[:limit] == 1 or args[:limit].nil?))
			begin
				case args[:service]
					when :spotify
						# Spotify track search (JSON)
						uri = URI.escape("http://ws.spotify.com/search/1/track.json?q=#{args[:artist].gsub("&","and").gsub(",","%20")} #{args[:title].gsub("&","and").gsub(",","%20")}")
						json = JSON.parse(open(uri).read)
						track = json['tracks'][0]
					when :rdio
						# Rdio track search (JSON)
						rdio = Rdio.new(["jnm9ynpuwpd6u37gxwam8eup", "Gvzh3a6ZGS"])
						json = rdio.call('search', {'query'=>"#{args[:artist]} #{args[:title]}", 'types' => 'Track', 'count' => 1})['result']
						track = json['results'][0]
					when :lastfm
						# Last.fm track search (XML)
						uri = URI.escape("http://ws.audioscrobbler.com/2.0/?method=track.getInfo&api_key=ed76a5bbe609896ac6a75709e0252691&artist=#{args[:artist].gsub("&","and").gsub(",","%20")}&track=#{args[:title].gsub("&","and").gsub(",","%20")}&autocorrect=1")
						track = Hash.from_xml(open(uri))['lfm']['track']
				end
			rescue OpenURI::HTTPError, Errno::ECONNREFUSED, Errno::ECONNRESET
				track = ''
			end
			return track
		
		elsif (args[:title] and args[:limit] > 1)
			begin
				case args[:service]
					when :spotify
						# Spotify track search (JSON)
						uri = URI.escape("http://ws.spotify.com/search/1/track.json?q=#{args[:artist].gsub("&","and").gsub(",","%20")} #{args[:title].gsub("&","and").gsub(",","%20")}")
						json = JSON.parse(open(uri).read)
						tracks = json['tracks'][0..args[:limit]]
					when :rdio
						# Rdio track search (JSON)
						rdio = Rdio.new(["jnm9ynpuwpd6u37gxwam8eup", "Gvzh3a6ZGS"])
						json = rdio.call('search', {'query'=>"#{args[:artist]} #{args[:title]}", 'types' => 'Track', 'count' => args[:limit]})['result']
						tracks = json['results']
					when :lastfm
						# Last.fm track search (XML)
						uri = URI.escape("http://ws.audioscrobbler.com/2.0/?method=track.search&api_key=ed76a5bbe609896ac6a75709e0252691&artist=#{args[:artist].gsub("&","and").gsub(",","%20")}&track=#{args[:title].gsub("&","and").gsub(",","%20")}&limit=#{args[:limit]}")
						tracks = Hash.from_xml(open(uri))['lfm']['results']['trackmatches']
				end
			rescue OpenURI::HTTPError, Errno::ECONNREFUSED, Errno::ECONNRESET
				tracks = ''
			end
			return tracks			
		end
	end
end
