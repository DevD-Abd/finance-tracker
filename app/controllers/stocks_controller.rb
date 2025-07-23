class StocksController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @stocks = current_user.stocks.order(:ticker)
  end

  def browse
    @search_query = params[:search]
    
    if @search_query.present?
      # Search in existing stocks first - using SQLite compatible case-insensitive search
      @stocks = Stock.where("UPPER(ticker) LIKE ? OR UPPER(name) LIKE ?", "%#{@search_query.upcase}%", "%#{@search_query.upcase}%")
      
      # If no results found, try to fetch from Alpha Vantage API to validate the ticker
      if @stocks.empty?
        ticker = @search_query.upcase.strip
        
        # Try to fetch from Alpha Vantage API regardless of format
        potential_stock = Stock.update_or_create_from_alpha_vantage(ticker)
        
        if potential_stock
          @stocks = [potential_stock]
          flash.now[:notice] = "Found and added #{ticker} from Alpha Vantage API"
        else
          flash.now[:alert] = "No stock data found for '#{@search_query}' on Alpha Vantage. Please check the ticker symbol."
          @stocks = []
        end
      end
    else
      # Show popular stocks if no search
      popular_tickers = %w[AAPL MSFT GOOGL AMZN TSLA META NFLX NVDA AMD INTC CRM ORCL IBM DIS BA]
      @stocks = Stock.where(ticker: popular_tickers).order(:ticker)
      
      # Fetch missing popular stocks
      missing_tickers = popular_tickers - @stocks.pluck(:ticker)
      missing_tickers.each do |ticker|
        stock = Stock.update_or_create_from_api(ticker)
        @stocks = (@stocks.to_a + [stock]).compact if stock
      end
    end
    
    @stocks = @stocks.to_a.uniq(&:ticker)
  end

  def show
    @stock = Stock.find_by(ticker: params[:id].upcase)
    @user_stock = current_user.user_stocks.find_by(stock: @stock) if @stock

    unless @stock
      @stock = Stock.update_or_create_from_api(params[:id])
      redirect_to stock_path(@stock.ticker) and return if @stock
    end
  end

  def create
    ticker = params[:ticker]&.upcase
    
    if ticker.blank?
      redirect_to stocks_path, alert: "Please enter a stock ticker symbol"
      return
    end
    
    # Check if user already tracks this stock
    existing_stock = Stock.find_by(ticker: ticker)
    if existing_stock && current_user.stocks.include?(existing_stock)
      redirect_to stocks_path, alert: "You are already tracking #{ticker}"
      return
    end
    
    # Fetch or create the stock
    @stock = existing_stock || Stock.update_or_create_from_api(ticker)

    if @stock
      # Add to user's portfolio
      current_user.user_stocks.find_or_create_by(stock: @stock)
      redirect_to stock_path(@stock.ticker), notice: "#{ticker} added to your portfolio!"
    else
      redirect_to stocks_path, alert: "Unable to fetch data for #{ticker}. Please check the ticker symbol and try again."
    end
  end

  def track
    @stock = Stock.find(params[:id])
    
    if current_user.stocks.include?(@stock)
      redirect_to browse_stocks_path, alert: "You are already tracking #{@stock.ticker}"
    else
      current_user.user_stocks.create(stock: @stock)
      redirect_to browse_stocks_path, notice: "#{@stock.ticker} added to your portfolio!"
    end
  end

  def untrack
    @user_stock = current_user.user_stocks.find_by(stock_id: params[:id])
    
    if @user_stock
      ticker = @user_stock.stock.ticker
      @user_stock.destroy
      redirect_to stocks_path, notice: "#{ticker} removed from your portfolio"
    else
      redirect_to stocks_path, alert: "Stock not found in your portfolio"
    end
  end

  def update
    @stock = Stock.find_by(ticker: params[:id].upcase)
    
    # Check if user tracks this stock
    unless current_user.stocks.include?(@stock)
      redirect_to stocks_path, alert: "You are not tracking this stock"
      return
    end
    
    if @stock
      updated_stock = @stock.update_price!
      if updated_stock == @stock && @stock.previous_changes.empty?
        redirect_to stock_path(@stock.ticker), alert: "Unable to update #{@stock.ticker} price. Please try again later."
      else
        redirect_to stock_path(@stock.ticker), notice: "#{@stock.ticker} price updated!"
      end
    else
      redirect_to stocks_path, alert: "Stock not found"
    end
  end
end
