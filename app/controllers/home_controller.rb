class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  
  def index
    if user_signed_in?
      redirect_to stocks_path
    end
  end
end
