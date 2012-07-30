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
			name = fix_utf8(mp3.at_css('#right_song div').content)
			unless mp3_info.to_i < 320 or name.downcase.include?("remix")
				url = mp3.at_css('#right_song div div div a')
				next if url.nil?
				next if url['href'].include?('4shared')
				link = {	'name' => name,
								 	'quality' => 320, 
								 	'url' => fix_utf8(url['href']), 
								 	'type' => 'Download', 
								 	'source' => 'MP3Skull' }
				links << link
				i += 1
			end
		end
		return links
	end
	
	protected
	def self.fix_utf8(untrusted_string)
		require 'iconv'
		ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
		valid_string = ic.iconv(untrusted_string + ' ')[0..-2]
	end
end
