FixedInvestment = require './fixedInvestment'

pricingOptions =
  btcSize: 0.01
  usdOffset: 0.33
  usdInterval: 0.99

# FixedInvestment 'BTC-USD', 1000, 250, 5, pricingOptions, 6

ethPricingOptions =
  btcSize: 1
  usdOffset: 0.02
  usdInterval: 0.05

FixedInvestment 'ETH-USD', 1000, 250, 5, ethPricingOptions, 6

# Create Updates of recent trades
# — save new trades to database for analysis
# — update on activity on a schedlued basis
# UPDATE_EVERY_HOURS = 1

# Updates = require './saveFills'

# Updates 'BTC-USD', UPDATE_EVERY_HOURS
