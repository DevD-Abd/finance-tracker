class Stock < ApplicationRecord
  validates :ticker, presence: true, uniqueness: true

  # Stock data with realistic company names and base prices (fallback)
  STOCK_DATA = {
    'AAPL' => { name: 'Apple Inc.', base_price: 175.0 },
    'MSFT' => { name: 'Microsoft Corporation', base_price: 350.0 },
    'GOOGL' => { name: 'Alphabet Inc. Class A', base_price: 140.0 },
    'AMZN' => { name: 'Amazon.com Inc.', base_price: 145.0 },
    'TSLA' => { name: 'Tesla Inc.', base_price: 250.0 },
    'META' => { name: 'Meta Platforms Inc.', base_price: 320.0 },
    'NFLX' => { name: 'Netflix Inc.', base_price: 450.0 },
    'NVDA' => { name: 'NVIDIA Corporation', base_price: 500.0 },
    'AMD' => { name: 'Advanced Micro Devices Inc.', base_price: 110.0 },
    'INTC' => { name: 'Intel Corporation', base_price: 45.0 },
    'CRM' => { name: 'Salesforce Inc.', base_price: 220.0 },
    'ORCL' => { name: 'Oracle Corporation', base_price: 105.0 },
    'IBM' => { name: 'International Business Machines Corporation', base_price: 140.0 },
    'DIS' => { name: 'The Walt Disney Company', base_price: 95.0 },
    'BA' => { name: 'The Boeing Company', base_price: 210.0 }
  }.freeze

  def self.update_or_create_from_alpha_vantage(ticker)
    require 'httparty'
    
    api_key = ENV['ALPHA_VANTAGE_API_KEY']
    return nil unless api_key.present?
    
    Rails.logger.info("Fetching real-time data for #{ticker} from Alpha Vantage...")
    
    # Alpha Vantage Global Quote endpoint
    url = "https://www.alphavantage.co/query"
    params = {
      function: 'GLOBAL_QUOTE',
      symbol: ticker.upcase,
      apikey: api_key
    }
    
    response = HTTParty.get(url, query: params, timeout: 10)
    
    if response.success? && response['Global Quote']
      quote_data = response['Global Quote']
      current_price = quote_data['05. price'].to_f
      
      stock = find_or_initialize_by(ticker: ticker.upcase)
      stock.last_price = current_price
      
      # Use symbol from API or fallback to our data
      if STOCK_DATA[ticker.upcase]
        stock.name = STOCK_DATA[ticker.upcase][:name] if stock.name.blank?
      else
        stock.name = "#{ticker.upcase} Corporation" if stock.name.blank?
      end
      
      stock.save!
      Rails.logger.info("✅ Real-time data from Alpha Vantage for #{ticker}: $#{stock.last_price}")
      stock
    elsif response['Note'] && response['Note'].include?('API call frequency')
      Rails.logger.warn("⚠️ Alpha Vantage API limit reached for #{ticker}")
      nil
    else
      Rails.logger.warn("❌ Alpha Vantage API failed for #{ticker}: #{response.inspect}")
      nil
    end
  rescue => e
    Rails.logger.error("❌ Alpha Vantage API error for #{ticker}: #{e.message}")
    nil
  end

  def self.update_or_create_from_yahoo(ticker)
    require 'httparty'
    
    Rails.logger.info("Trying Yahoo Finance for #{ticker}...")
    url = "https://query1.finance.yahoo.com/v8/finance/chart/#{ticker.upcase}"
    response = HTTParty.get(url, timeout: 5)
    
    if response.success? && response['chart']['result']
      result = response['chart']['result'][0]
      meta = result['meta']
      current_price = meta['regularMarketPrice'] || meta['previousClose']
      company_name = meta['longName'] || "#{ticker.upcase} Inc."
      
      stock = find_or_initialize_by(ticker: ticker.upcase)
      stock.last_price = current_price.to_f
      stock.name = company_name if stock.name.blank?
      stock.save!
      
      Rails.logger.info("✅ Yahoo Finance data saved for #{ticker}: $#{stock.last_price}")
      stock
    else
      Rails.logger.warn("❌ Yahoo Finance failed for #{ticker}")
      nil
    end
  rescue => e
    Rails.logger.error("❌ Yahoo Finance error for #{ticker}: #{e.message}")
    nil
  end

  def self.update_or_create_from_realistic_data(ticker)
    Rails.logger.info("Using realistic simulation for #{ticker}...")
    ticker_upcase = ticker.upcase
    stock_info = STOCK_DATA[ticker_upcase]
    
    if stock_info
      # Create realistic price fluctuation (±10% from base price)
      variation = (rand - 0.5) * 0.2 # -10% to +10%
      current_price = (stock_info[:base_price] * (1 + variation)).round(2)
      
      stock = find_or_initialize_by(ticker: ticker_upcase)
      stock.last_price = current_price
      stock.name = stock_info[:name] if stock.name.blank?
      stock.save!
      
      Rails.logger.info("✅ Realistic data created for #{ticker}: $#{stock.last_price}")
      stock
    else
      # For unknown tickers, create generic data
      stock = find_or_initialize_by(ticker: ticker_upcase)
      stock.last_price = rand(20.0..300.0).round(2)
      stock.name = "#{ticker_upcase} Corporation" if stock.name.blank?
      stock.save!
      
      Rails.logger.info("✅ Generic data created for #{ticker}: $#{stock.last_price}")
      stock
    end
  rescue => e
    Rails.logger.error("Stock creation error: #{e.message}")
    nil
  end

  # Main method - tries real APIs first, falls back to simulation
  def self.update_or_create_from_api(ticker)
    Rails.logger.info("🔄 Fetching data for #{ticker}...")
    
    # First try Alpha Vantage (real-time data)
    if ENV['ALPHA_VANTAGE_API_KEY'].present?
      result = update_or_create_from_alpha_vantage(ticker)
      return result if result
    end
    
    # Then try Yahoo Finance
    begin
      Timeout::timeout(5) do
        result = update_or_create_from_yahoo(ticker)
        return result if result
      end
    rescue Timeout::Error, StandardError => e
      Rails.logger.info("External APIs failed, using realistic data: #{e.message}")
    end
    
    # Fallback to realistic data
    update_or_create_from_realistic_data(ticker)
  end

  # Method to update price with real-time data
  def update_price!
    Rails.logger.info("🔄 Updating price for #{self.ticker}...")
    
    # Try to get real-time data first
    if ENV['ALPHA_VANTAGE_API_KEY'].present?
      updated_stock = Stock.update_or_create_from_alpha_vantage(self.ticker)
      if updated_stock
        self.reload
        return self
      end
    end
    
    # Fallback to simulation for existing stocks
    if STOCK_DATA[self.ticker]
      base_price = STOCK_DATA[self.ticker][:base_price]
      variation = (rand - 0.5) * 0.1 # ±5% change
      self.last_price = (base_price * (1 + variation)).round(2)
    else
      # For unknown stocks, small random change
      change = (rand - 0.5) * 0.1 # ±5% change
      self.last_price = (self.last_price * (1 + change)).round(2)
    end
    save!
    Rails.logger.info("✅ Price updated for #{self.ticker}: $#{self.last_price}")
    self
  end
end
