class Stock < ApplicationRecord
    has_many :user_stocks
    has_many :users, through: :user_stocks

  validates :ticker, presence: true, uniqueness: true

  # Stock data with realistic company names (for fallback only)
  STOCK_DATA = {
    'AAPL' => { name: 'Apple Inc.' },
    'MSFT' => { name: 'Microsoft Corporation' },
    'GOOGL' => { name: 'Alphabet Inc. Class A' },
    'AMZN' => { name: 'Amazon.com Inc.' },
    'TSLA' => { name: 'Tesla Inc.' },
    'META' => { name: 'Meta Platforms Inc.' },
    'NFLX' => { name: 'Netflix Inc.' },
    'NVDA' => { name: 'NVIDIA Corporation' },
    'AMD' => { name: 'Advanced Micro Devices Inc.' },
    'INTC' => { name: 'Intel Corporation' },
    'CRM' => { name: 'Salesforce Inc.' },
    'ORCL' => { name: 'Oracle Corporation' },
    'IBM' => { name: 'International Business Machines Corporation' },
    'DIS' => { name: 'The Walt Disney Company' },
    'BA' => { name: 'The Boeing Company' }
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
      
      # Check if we got valid data
      if current_price > 0
        stock = find_or_initialize_by(ticker: ticker.upcase)
        stock.last_price = current_price
        
        # Use company name from our data
        if STOCK_DATA[ticker.upcase]
          stock.name = STOCK_DATA[ticker.upcase][:name] if stock.name.blank?
        else
          stock.name = "#{ticker.upcase} Corporation" if stock.name.blank?
        end
        
        stock.save!
        Rails.logger.info("✅ Real-time data from Alpha Vantage for #{ticker}: $#{stock.last_price}")
        stock
      else
        Rails.logger.warn("❌ Alpha Vantage returned invalid price for #{ticker}")
        nil
      end
    elsif response['Note'] && response['Note'].include?('API call frequency')
      Rails.logger.warn("⚠️ Alpha Vantage API limit reached for #{ticker}")
      nil
    else
      Rails.logger.warn("❌ Alpha Vantage API failed for #{ticker}")
      nil
    end
  rescue => e
    Rails.logger.error("❌ Alpha Vantage API error for #{ticker}: #{e.message}")
    nil
  end

  # Main method - tries Alpha Vantage, returns error if fails
  def self.update_or_create_from_api(ticker)
    Rails.logger.info("🔄 Fetching data for #{ticker}...")
    
    # Try Alpha Vantage (real-time data)
    if ENV['ALPHA_VANTAGE_API_KEY'].present?
      result = update_or_create_from_alpha_vantage(ticker)
      return result if result
    end
    
    # If Alpha Vantage fails, return nil (no fallbacks)
    Rails.logger.error("❌ Unable to fetch data for #{ticker} - Alpha Vantage API failed")
    nil
  end

  # Method to update price with real-time data
  def update_price!
    Rails.logger.info("🔄 Updating price for #{self.ticker}...")
    
    # Get real-time data from Alpha Vantage
    if ENV['ALPHA_VANTAGE_API_KEY'].present?
      updated_stock = Stock.update_or_create_from_alpha_vantage(self.ticker)
      if updated_stock
        self.reload
        return self
      end
    end
    
    # If Alpha Vantage fails, don't update the price
    Rails.logger.error("❌ Unable to update price for #{self.ticker} - Alpha Vantage API failed")
    self
  end
end
