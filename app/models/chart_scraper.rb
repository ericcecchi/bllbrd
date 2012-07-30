class ChartScraper
	require 'nokogiri'
	require 'open-uri'
	
	def self.scrape(args)
	# Given a chart type, returns a list of song hashes with the following keys:
	# :title, :artist, :featuring, :album, :position, :chart
	
		case args[:chart]
			when :rock_songs
				# Billboard Rock Songs
				url = "http://www.billboard.com/rss/charts/rock-songs"
				songs = billboard(url, 'Billboard Rock')
			when :hot100
				# Billboard Hot 100
				url = "http://www.billboard.com/rss/charts/hot-100"
				songs = billboard(url, 'Billboard Hot 100')
			when :pop_songs
				# Billboard Pop Songs
				url = "http://www.billboard.com/rss/charts/pop-songs"
				songs = billboard(url, 'Billboard Pop')
			when :alternative_songs
				# Billboard Alternative Songs
				url = "http://www.billboard.com/rss/charts/alternative-songs"
				songs = billboard(url, 'Billboard Alternative')
			when :hiphop_songs
				# Billboard R&B/Hip-Hop Songs
				url = "http://www.billboard.com/rss/charts/r-b-hip-hop-songs"
				songs = billboard(url, 'Billboard R&B/Hip-Hop')
		end
		
		return songs
	end
	
	private
	def self.billboard(url,chart)
		songs = []
		doc = Nokogiri::XML(open(url))
		doc.xpath('//item/title').each do |node|
			song = {}
			content = node.text.split(':',2)
			position = content[0]
			title, artist_featuring = content[1].split(',',2)
			artist_name, featuring_name = artist_featuring.split(' Featuring ')
			song[:title] = title.strip
			song[:artist] = artist_name.strip
			song[:featuring] = featuring_name.strip if featuring_name
			song[:album] = title.strip
			song[:position] = position
			song[:chart] = chart
			songs << song
		end
		return songs
	end
	
	def self.process(songs, playlist)
	# Processes a list of song hashes. Retrieves song info using service API's.
	# Adds processed songs to database.
	
		songs.each do |song_hash|
		# 	next if song_hash[:position].to_i < 78 # for debugging crashes at a specific song
			service = :rdio
			track = ServiceApi.get_track(title: song_hash[:title], artist: song_hash[:artist], service: service)
		
		# 	print track
			artist_name = song_hash[:artist]
			case service
			when :rdio
				artist_name = track['artist'].split(' feat. ')[0].split(' ft. ')[0].split(' Feat. ')[0] || song_hash[:artist]
				album_name = track['album'] || ''
				song_name = track['name'] || song_hash[:title]
			when :spotify
				if track['album']
					album_name = track['album']['name'] || ''
				else
					album_name = ''
				end
				song_name = track['name'] || song_hash[:title]
			when :lastfm
				lastfm_artist_hash = ServiceApi.get_artist(key: track['artist']['mbid'], service: :lastfm)
				lastfm_album_hash = ServiceApi.get_album(key: track['album']['mbid'], service: :lastfm)
				if track[:album]
					album_name = track[:album][:title] || ''
				else
					album_name = ''
				end
				song_name = track[:name] || song_hash[:title]
			else
				artist_name = song_hash[:artist]
				album_name = ''
				song_name = song_hash[:title]
		end
			
			artist = Artist.where(name:	artist_name).first
			song = Song.where(name: song_name, album_artist_id: artist._id).first if artist
			unless song
			song = Song.create(name: song_name, artist_name: artist_name, album_name: album_name)
			song.update_attributes(featuring_name: song_hash[:featuring]) if song_hash[:featuring]
			song.update_hash()
		end
			song.update_attributes(tag_names: song_hash[:chart])
			if song.playlists.include?(playlist)
			r = Ranking.where(song_id: song._id, playlist_id: playlist._id).first
			if r
				r.position = song_hash[:position].to_i
				r.peak = song_hash[:position].to_i if song_hash[:position].to_i > r.peak
				r.weeks += 1
				r.save
			else
				r = Ranking.create(song_id: song._id, playlist_id: playlist._id, position: song_hash[:position], peak: song_hash[:position])
			end		
		else
			r = Ranking.create(song_id: song._id, playlist_id: playlist._id, position: song_hash[:position], peak: song_hash[:position])
		end
			puts "Added #{song_hash[:chart]} ##{r.position}: #{song.name} by #{song.artist_name} in #{song.album_name}"
		end
	end
end
