# hot100: "Billboard Hot 100", 
charts = { rock_songs: "Billboard Rock Songs", pop_songs: "Billboard Pop Songs", alternative_songs: "Billboard Alternative Songs", hiphop_songs: "Billboard R&B/Hip-Hop Songs" }
charts.each do |chart|
	songs = ChartScraper.scrape(chart: chart[0])
	playlist = Playlist.find_or_create_by(name: chart[1])
	playlist.rankings.destroy_all
	ChartScraper.process(songs, playlist)
end
