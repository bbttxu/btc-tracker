FixedInvestment = require './fixedInvestment'

pricingOptions =
  btcSize: 0.1
  usdOffset: 0.33
  usdInterval: 0.99
  minimumSize: 0.01

FixedInvestment 'BTC-USD', 1000, pricingOptions, 2.5

ethPricingOptions =
  btcSize: 1.00
  usdOffset: 0.02
  usdInterval: 0.05
  minimumSize: 0.1

FixedInvestment 'ETH-USD', 1250, ethPricingOptions, 2.5

# Create Updates of recent trades
# — save new trades to database for analysis
# — update on activity on a schedlued basis
UPDATE_EVERY_HOURS = 1

Updates = require './saveFills'

Updates 'BTC-USD', UPDATE_EVERY_HOURS
Updates 'ETH-USD', UPDATE_EVERY_HOURS


Daily = require('./daily')()
