FixedInvestment = require './fixedInvestment'

FixedInvestment 1200, 250, 5, 0.11, 6

# Create Updates of recent trades
# — save new trades to database for analysis
# — update on activity on a schedlued basis
UPDATE_EVERY_HOURS = 1

Updates = require './saveFills'

Updates UPDATE_EVERY_HOURS
