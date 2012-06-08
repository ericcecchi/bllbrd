class SkullScraper
	require 'nokogiri'
	require 'open-uri'
	
	def self.scrape(args={})
		links = []
		limit = args[:limit] || 5
		query = "#{args[:track]} #{args[:artist]}".parameterize
		if query == ''
			return []
		end
		i = 0
		doc = Nokogiri::XML(open("http://mp3skull.com/mp3/#{query}.html"))
		doc.css('#song_html').each do |mp3|
			break if i > limit
			mp3_info = mp3.at_css('div').content
			unless mp3_info.to_i < 320 or mp3.at_css('#right_song div').content.downcase.include?("remix")
				next if mp3.at_css('#right_song div div div a')['href'].include?('4shared')
				link = {	name: mp3.at_css('#right_song div').content,
								 	quality: 320, url: mp3.at_css('#right_song div div div a')['href'], 
								 	type: 'Download', 
								 	source: 'MP3Skull' }
				links << link
				i += 1
			end
		end
		return links
	end
end
