class StocksController < ApplicationController
  def index
    @stocks = Stock.all.order(:ticker)
  end

  def show
    @stock = Stock.find_by(ticker: params[:id].upcase)

    unless @stock
      @stock = Stock.update_or_create_from_api(params[:id])
      redirect_to stock_path(@stock.ticker) and return if @stock
    end
  end

  def create
    ticker = params[:ticker].upcase
    
    if ticker.blank?
      redirect_to stocks_path, alert: "Please enter a stock ticker symbol"
      return
    end
    
    @stock = Stock.update_or_create_from_api(ticker)

    if @stock
      redirect_to stock_path(@stock.ticker), notice: "#{ticker} added to your portfolio!"
    else
      redirect_to stocks_path, alert: "Unable to fetch data for #{ticker}. Please check the ticker symbol and try again."
    end
  end

  def update
    @stock = Stock.find_by(ticker: params[:id].upcase)
    
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
