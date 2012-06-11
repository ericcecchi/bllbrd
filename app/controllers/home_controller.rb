class HomeController < ApplicationController
	def index
		redirect_to '/songs' if current_user
	end
end
