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
		
		if args[:service] == :mp3skull
			service = "MP3Skull"
			url = "http://mp3skull.com/mp3/#{query}.html"
			song_html = '#song_html'
			mp3_html = 'div'
			name_html = '#right_song div'
			url_html = '#right_song div div div a'
		elsif args[:service] == :mp3chief
			service = "MP3Chief"
			url = "http://www.mp3chief.com/music/#{query.parameterize}"
			song_html = 'div.song_item'
			mp3_html = 'div.song_info'
			name_html = 'div.song_common span'
			url_html = 'div.download_link a'
		end
		
		i = 0
		begin
			doc = Nokogiri::XML(open(url))
			doc.css(song_html).each do |mp3|
				break if i > limit
				mp3_info = mp3.at_css(mp3_html).content
				name = fix_utf8(mp3.at_css(name_html).content)
				unless mp3_info.to_i < 320 or name.downcase.include?("remix")
					url = mp3.at_css(url_html)
					next if url.nil?
					next if url['href'].include?('4shared')
					link = {	name: name,
									 	quality: 320, 
									 	url: fix_utf8(url['href']), 
									 	type: :download, 
									 	site: service }
					links << link
					i += 1
				end
			end
		rescue OpenURI::HTTPError, Errno::ECONNREFUSED, Errno::ECONNRESET
			links = []
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
