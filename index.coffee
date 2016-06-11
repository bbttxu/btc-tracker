FixedInvestment = require './fixedInvestment'

pricingOptions =
  btcSize: 0.01
  usdOffset: 0.11
  usdInterval: 0.33

FixedInvestment 'BTC-USD', 1000, 250, 5, pricingOptions, 6

ethPricingOptions =
  btcSize: 0.5
  usdOffset: 0.01
  usdInterval: 0.02

FixedInvestment 'ETH-USD', 100, 250, 5, ethPricingOptions, 10

# Create Updates of recent trades
# — save new trades to database for analysis
# — update on activity on a schedlued basis
# UPDATE_EVERY_HOURS = 1

# Updates = require './saveFills'

# Updates 'BTC-USD', UPDATE_EVERY_HOURS
