require 'nokogiri'
require 'open-uri'
require './rdio'

# tester = URI.escape('http://ws.audioscrobbler.com/2.0/?method=track.getInfo&api_key=ed76a5bbe609896ac6a75709e0252691&artist=asdfasd&track=dfasd')
# Nokogiri::XML(open(tester))
doc = Nokogiri::XML(open("http://www.billboard.com/rss/charts/hot-100"))
songs =[]
doc.xpath('//item/title').each do |node|
	content = node.text.split(':')
	position = content[0]
	title, artist_featuring = content[1].split(',')
	artist_name, featuring_name = artist_featuring.split(' Featuring ')
	artist_name.strip!
	featuring_name.strip! if featuring_name
	title.strip!
	
#		# Last.fm album search
# 	last_uri = URI.escape("http://ws.audioscrobbler.com/2.0/?method=track.getInfo&api_key=ed76a5bbe609896ac6a75709e0252691&artist=#{artist_name.gsub("&","and").gsub(",","%20")}&track=#{title.gsub("&","and").gsub(",","%20")}")
# 	puts last_uri
# 	begin
# 		track = Nokogiri::XML(open(last_uri))
# 		if track.xpath('//title').first
# 			album_name = track.xpath('//title').first.text
# 		else
# 			album_name = ""
# 		end
# 	rescue OpenURI::HTTPError
# 		album_name = ""
# 	end

#		# Spotify album search
# 	spotify_uri = URI.escape("http://ws.spotify.com/search/1/track?q=#{artist_name.gsub("&","and").gsub(",","%20")} #{title.gsub("&","and").gsub(",","%20")}")
# 	puts spotify_uri
# 	begin
# 		track = Nokogiri::XML(open(spotify_uri))
# 		if track.css('track album').first
# 			album_name = track.css('track album name').first.text
# 			year = track.css('track album released').first.text
# 		else
# 			album_name = title
# 			year = Date.today.year
# 		end
# 	rescue OpenURI::HTTPError, Errno::ECONNREFUSED, Errno::ECONNRESET
# 		album_name = title
# 		year = Date.today.year
# 	end

# 	# Spotify album search (JSON)
# 	spotify_uri = URI.escape("http://ws.spotify.com/search/1/track.json?q=#{artist_name.gsub("&","and").gsub(",","%20")} #{title.gsub("&","and").gsub(",","%20")}")
# # 	puts spotify_uri
# 	begin
# 	spotify_json = JSON.parse(open(spotify_uri).read)
# 		track = spotify_json['tracks'][0]
# 		if track
# 			if track['album']
# 				album_name = track['album']['name']
# 				year = track['album']['released']
# 			else
# 				album_name = title
# 				year = Date.today.year
# 			end
# 		end
# 	rescue OpenURI::HTTPError, Errno::ECONNREFUSED, Errno::ECONNRESET
# 		album_name = title
# 		year = Date.today.year
# 	end
	
	# Rdio
	rdio = Rdio.new(["jnm9ynpuwpd6u37gxwam8eup", "Gvzh3a6ZGS"])
	begin
		track = rdio.call('search', {'query'=>"#{artist_name} #{title}", 'types' => 'Track', 'count' => 1})['result']['results'][0]
		if track
			if track['album']
				album_name = track['album']
				album_key = track['albumKey']
				track_key = track['key']
				artist_key = track['artistKey']
				response = rdio.call('get', {'keys'=> album_key})
				album = response['result'][album_key] if response['status']['ok']
		 		year = album['releaseDate'].split('-')[0] if album['releaseDate']
			else
				album_name = title
				year = Date.today.year
			end
		end
	rescue OpenURI::HTTPError, Errno::ECONNREFUSED, Errno::ECONNRESET
		album_name = title
		year = Date.today.year
	end

	puts "#{title} by #{artist_name} featuring #{featuring_name} in #{album_name} (#{year})"
end