# 📈 Finance Tracker

A modern Rails application for tracking your stock portfolio with real-time price updates and a beautiful, responsive interface.

## ✨ Features

- **Portfolio Management**: Add and track your favorite stocks
- **Real-time Prices**: Get current stock prices with realistic data simulation
- **Beautiful UI**: Modern, responsive design with Tailwind CSS
- **Price Updates**: Refresh individual stock prices or update all at once
- **User Authentication**: Secure login/signup with Devise
- **Mobile Friendly**: Works perfectly on desktop and mobile devices

## 🚀 Quick Start

1. **Start the development server:**
   ```bash
   .\bin\dev
   ```

2. **Visit the application:**
   Open your browser to `http://localhost:3000`

3. **Add stocks to your portfolio:**
   - Use the form on the homepage to add stocks by ticker symbol
   - Try popular stocks: AAPL, MSFT, GOOGL, AMZN, TSLA, META, NFLX, NVDA

## 📊 Real-Time Stock Data

The application provides **real-time stock data** using:
- **Alpha Vantage API** - Professional market data service
- **Clean implementation** - No fallbacks or simulation data
- **Real market prices** from major exchanges

### 🔴 Live Data Features:
- **Real market prices** from Alpha Vantage
- **Rate limiting protection** (12-second delays between API calls)
- **Error handling** for API failures
- **15 Major companies** pre-configured with proper names

### 📈 API Requirements:
- **Alpha Vantage API Key** required (free tier available)
- **5 API calls per minute** on free tier
- **500 calls per day** on free tier
- **Automatic rate limiting** built-in

## 🛠️ Rake Tasks

### Add Sample Stocks
```bash
rails stocks:add_samples
```
Adds popular stocks to your portfolio for demo purposes.

### Update All Prices
```bash
rails stocks:update_prices
```
Updates prices for all stocks in your portfolio with realistic fluctuations.

## 🎨 Technology Stack

- **Ruby on Rails 8.0**
- **Tailwind CSS** for styling
- **SQLite** database
- **Devise** for authentication
- **Stimulus** for JavaScript interactions
- **Turbo** for SPA-like experience

---

**Happy Trading! 📈💰**