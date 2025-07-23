class UsersController < ApplicationController
  before_action :authenticate_user!
  
  def show
    @user = User.find(params[:id])
    @stocks = @user.stocks.order(:ticker)
    @is_friend = current_user.friends.include?(@user)
    @friendship = current_user.friendships.find_by(friend: @user) if @is_friend
    @is_current_user = current_user == @user
  rescue ActiveRecord::RecordNotFound
    redirect_to friendships_path, alert: "User not found"
  end
end
