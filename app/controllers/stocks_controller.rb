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
    @stock = Stock.update_or_create_from_api(ticker)

    if @stock
      redirect_to stock_path(@stock.ticker), notice: "#{ticker} added to your portfolio!"
    else
      redirect_to stocks_path, alert: "Failed to add #{ticker} to your portfolio"
    end
  end

  def update
    @stock = Stock.find_by(ticker: params[:id].upcase)
    
    if @stock
      @stock.update_price!
      redirect_to stock_path(@stock.ticker), notice: "#{@stock.ticker} price updated!"
    else
      redirect_to stocks_path, alert: "Stock not found"
    end
  end
end
