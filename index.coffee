config = require './config'

FixedInvestment = require './fixedInvestment'

FixedInvestment 'BTC-USD', 1500, config.pricingOptions, 5
FixedInvestment 'ETH-USD', 1000, config.ethPricingOptions, 5
FixedInvestment 'LTC-USD', 200, config.ltcPricingOptions, 5

# Create Updates of recent trades
# — save new trades to database for analysis
# — update on activity on a schedlued basis
UPDATE_EVERY_HOURS = 1

Updates = require './saveFills'

Updates 'BTC-USD', UPDATE_EVERY_HOURS
Updates 'ETH-USD', UPDATE_EVERY_HOURS
Updates 'LTC-USD', UPDATE_EVERY_HOURS


Daily = require('./daily')()
