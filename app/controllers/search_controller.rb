class SearchController < ApplicationController
	def index
	  @songs = Song.fulltext_search(params[:search])
	  @artists = Artist.fulltext_search(params[:search])
	end
end
