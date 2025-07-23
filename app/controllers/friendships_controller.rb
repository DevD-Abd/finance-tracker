class FriendshipsController < ApplicationController
  before_action :authenticate_user!

  def index
    @search_query = params[:search]
    
    # Get friends
    @friends = current_user.friends.order(:first_name, :last_name, :email)
    
    # Apply search filter to friends if search query exists
    if @search_query.present?
      @friends = @friends.where(
        "UPPER(first_name) LIKE ? OR UPPER(last_name) LIKE ? OR UPPER(email) LIKE ?", 
        "%#{@search_query.upcase}%", 
        "%#{@search_query.upcase}%", 
        "%#{@search_query.upcase}%"
      )
    end
    
    # Get all non-friend users
    @all_users = User.where.not(id: current_user.id)
                     .where.not(id: current_user.friends.ids)
                     .order(:first_name, :last_name, :email)
    
    # Apply search filter to all users if search query exists
    if @search_query.present?
      @all_users = @all_users.where(
        "UPPER(first_name) LIKE ? OR UPPER(last_name) LIKE ? OR UPPER(email) LIKE ?", 
        "%#{@search_query.upcase}%", 
        "%#{@search_query.upcase}%", 
        "%#{@search_query.upcase}%"
      )
    end
  end

  def create
    @friend = User.find(params[:friend_id])
    
    if current_user.friends.include?(@friend)
      redirect_to friendships_path, alert: "#{@friend.display_name} is already your friend"
    else
      current_user.friendships.create(friend: @friend)
      redirect_to friendships_path, notice: "#{@friend.display_name} added as friend!"
    end
  end

  def destroy
    @friendship = current_user.friendships.find(params[:id])
    friend_name = @friendship.friend.display_name
    @friendship.destroy
    redirect_to friendships_path, notice: "#{friend_name} removed from friends"
  end
end
