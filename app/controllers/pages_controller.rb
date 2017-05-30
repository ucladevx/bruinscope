class PagesController < ApplicationController
	def home
    # Paginate posts by pages using will_paginate gem
    @posts = Post.paginate(page: params[:page], per_page: 3).order('created_at desc')
    # Change this to top 12 companies
    @companies = Company.all
    # Respond to the AJAX request coming from pagination.coffee with the appropriate resource
    respond_to do |format|
    	format.html # home.html.erb
    	format.js # home.js.erb
		end
	end
end
