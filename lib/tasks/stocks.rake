namespace :stocks do
  desc "Update all stock prices with real-time data"
  task update_prices: :environment do
    puts "🔄 Updating stock prices with real-time data..."
    puts "📡 Using Alpha Vantage API: #{ENV['ALPHA_VANTAGE_API_KEY'].present? ? 'Yes' : 'No'}"
    puts ""
    
    Stock.all.each_with_index do |stock, index|
      old_price = stock.last_price
      
      # Add delay to avoid API rate limits (Alpha Vantage allows 5 calls per minute for free)
      if index > 0 && ENV['ALPHA_VANTAGE_API_KEY'].present?
        puts "⏳ Waiting 12 seconds to avoid API rate limit..."
        sleep 12
      end
      
      stock.update_price!
      change = stock.last_price - old_price
      change_percent = (change / old_price * 100).round(2)
      
      status = change_percent > 0 ? "📈" : change_percent < 0 ? "📉" : "➡️"
      puts "#{status} #{stock.ticker}: $#{old_price} → $#{stock.last_price} (#{change_percent > 0 ? '+' : ''}#{change_percent}%)"
    end
    
    puts ""
    puts "✅ All stock prices updated with real-time data!"
  end

  desc "Add sample stocks for demo"
  task add_samples: :environment do
    sample_tickers = %w[AAPL MSFT GOOGL AMZN TSLA META NFLX NVDA AMD INTC]
    
    puts "📈 Adding sample stocks with real-time data..."
    puts "📡 Using Alpha Vantage API: #{ENV['ALPHA_VANTAGE_API_KEY'].present? ? 'Yes' : 'No'}"
    puts ""
    
    sample_tickers.each_with_index do |ticker, index|
      unless Stock.exists?(ticker: ticker)
        # Add delay to avoid API rate limits
        if index > 0 && ENV['ALPHA_VANTAGE_API_KEY'].present?
          puts "⏳ Waiting 12 seconds to avoid API rate limit..."
          sleep 12
        end
        
        stock = Stock.update_or_create_from_api(ticker)
        puts "✅ Added: #{stock.ticker} - #{stock.name} ($#{stock.last_price})" if stock
      else
        puts "ℹ️ #{ticker} already exists"
      end
    end
    
    puts ""
    puts "🎉 Sample stocks added with real-time data!"
  end
end
