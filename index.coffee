FixedInvestment = require './fixedInvestment'

FixedInvestment 1000, 500, 5, 0.33, 15

# Create Updates of recent trades
# — save new trades to database for analysis
# — update on activity on a schedlued basis
UPDATE_EVERY_HOURS = 8

Updates = require './saveFills'

Updates UPDATE_EVERY_HOURS
