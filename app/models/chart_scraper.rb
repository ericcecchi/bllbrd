class ChartScraper
	require 'nokogiri'
	require 'open-uri'
	
	def self.scrape(args)		
		case args[:chart]
			when :hot100
				# Billboard Hot 100
				songs = []
				doc = Nokogiri::XML(open("http://www.billboard.com/rss/charts/hot-100"))
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
					song[:chart] = 'Hot 100'
					songs << song
				end
			end
		return songs
	end
end
