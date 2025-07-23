namespace :stocks do
  desc "Update all stock prices with real-time Alpha Vantage data"
  task update_prices: :environment do
    puts "🔄 Updating stock prices with Alpha Vantage API..."
    puts ""
    
    Stock.all.each_with_index do |stock, index|
      old_price = stock.last_price
      
      # Add delay to respect API rate limits (5 calls per minute for free tier)
      if index > 0
        puts "⏳ Waiting 12 seconds to respect API rate limit..."
        sleep 12
      end
      
      stock.update_price!
      
      if stock.previous_changes.any?
        change = stock.last_price - old_price
        change_percent = (change / old_price * 100).round(2)
        status = change_percent > 0 ? "📈" : change_percent < 0 ? "📉" : "➡️"
        puts "#{status} #{stock.ticker}: $#{old_price} → $#{stock.last_price} (#{change_percent > 0 ? '+' : ''}#{change_percent}%)"
      else
        puts "⚠️ #{stock.ticker}: Unable to update price"
      end
    end
    
    puts ""
    puts "✅ Price update complete!"
  end

  desc "Add sample stocks with real-time data"
  task add_samples: :environment do
    sample_tickers = %w[AAPL MSFT GOOGL AMZN TSLA META NFLX NVDA AMD INTC]
    
    puts "📈 Adding sample stocks with Alpha Vantage data..."
    puts ""
    
    sample_tickers.each_with_index do |ticker, index|
      unless Stock.exists?(ticker: ticker)
        # Add delay to respect API rate limits
        if index > 0
          puts "⏳ Waiting 12 seconds to respect API rate limit..."
          sleep 12
        end
        
        stock = Stock.update_or_create_from_api(ticker)
        if stock
          puts "✅ Added: #{stock.ticker} - #{stock.name} ($#{stock.last_price})"
        else
          puts "❌ Failed to add: #{ticker}"
        end
      else
        puts "ℹ️ #{ticker} already exists"
      end
    end
    
    puts ""
    puts "🎉 Sample stocks task complete!"
  end
end
