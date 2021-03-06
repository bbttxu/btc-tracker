config = require './config'

UPDATE_MINS = 2.5

FixedInvestment = require './fixedInvestment'

FixedInvestment 'BTC-USD', 1500, config.pricingOptions, UPDATE_MINS
FixedInvestment 'ETH-USD', 1000, config.ethPricingOptions, UPDATE_MINS
# FixedInvestment 'LTC-USD', 0, config.ltcPricingOptions, UPDATE_MINS

# Create Updates of recent trades
# — save new trades to database for analysis
# — update on activity on a schedlued basis
UPDATE_EVERY_HOURS = 1

Updates = require './saveFills'

Updates 'BTC-USD', UPDATE_EVERY_HOURS
Updates 'ETH-USD', UPDATE_EVERY_HOURS
Updates 'LTC-USD', UPDATE_EVERY_HOURS


Daily = require('./daily')()
