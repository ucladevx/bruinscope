class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  def list
    @posts = Post.all
  end

  def show
    # Get the post id from the URL params
    @post = Post.find(params[:id])
    @new_comment = Comment.build_from(@post, current_user.id, "")

    # Respond to a remote call (AJAX) with some javascript
    respond_to do |format|
      format.html # This will invoke show.html.erb
      format.js # This will invoke show.js.erb that should be in the views/posts/ folder and will have access to @post
    end
  end

  def new
    @post = Post.new
    respond_to do |format|
    	format.html
      format.js
		end
  end

  def create
    @post = Post.new(post_params) do |post|
      unless params.key?("anonymous")
        post.user = current_user
      end
      post.company = Company.where(name: params[:company_name]).first
      post.role = params[:role]
      post.difficulty = params[:difficulty]
      post.offer = params[:offer]
    end
    respond_to do |format|
      if @post.save
        @post_json = JSON::parse(@post.to_json).merge({url: post_url(@post)})
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
        format.js { render json: @post_json, content_type: 'application/json' }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
        format.js { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def upvote
    # Get the post id from the URL params
    @post = Post.find(params[:post_id])
    @user = current_user
    if @user.present?
      if !(@user.voted_for? @post)
        @post.liked_by current_user
      else
        @post.unliked_by current_user
      end
      respond_to do |format|
        # add in upvote value to json
        @post_json = JSON::parse(@post.to_json).merge({upvote: @post.votes_for.size})
        # post json to page let EventHandler handle
        format.js { render json: @post_json, content_type: 'application/json' }
      end
    else
      puts "\n\n\n\n"
      puts "Not logged in."
    end
  end

=begin
  Comments v1.
  def comment
    puts "[TEST OUTPUT]: On comment click"
    @post = Post.find(params[:post_id])
    @user = current_user

    respond_to do |format|
      @comment = Comment.build_from( @post, @user.id, "Test comment" )
      @all_comments = @post.comment_threads
      puts @all_comments

      @all_comments.each do |child_comment|
        puts "hello"
        puts "Content" + child_comment
      end
      format.js { render json: @post.to_json, content_type: 'application/json' }
    end
  end
=end

  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:post).permit(:title, :experience, :question, :company_name, :position, :resources, :role, :difficulty, :offer, :anonymous)
    end
end
