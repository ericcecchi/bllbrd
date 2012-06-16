class Youtune5
	require 'httparty'
	include HTTParty
  
  def self.search(terms)
    json = get('https://gdata.youtube.com/feeds/api/videos?max-results=1', :query => {:q => terms, :alt => 'json'}).body
    results = JSON.parse(json)
  	"#{results['feed']['entry'][0]['id']['$t'].gsub("http://gdata.youtube.com/feeds/api/videos/",'') if results['feed']['entry']}"
  end
  
  def self.embed(video)
  	"<iframe id=\"youtube\" src=\"http://www.youtube.com/embed/#{video}\" width=1280 height=720 frameborder=0 type=\"text/html\"></iframe>"
  end
end