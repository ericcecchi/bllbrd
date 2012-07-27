# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#		cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#		Mayor.create(name: 'Emanuel', city: cities.first)
		
songs = ChartScraper.scrape(chart: :hot100)
playlist = Playlist.find_or_create_by(name: 'Billboard Hot 100')
playlist.rankings.destroy_all

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
	puts "Added Billboard Hot 100 ##{r.position}: #{song.name} by #{song.artist_name} in #{song.album_name}"
end
