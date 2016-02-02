R = require 'ramda'
acct = require 'accounting'

# Show a running total up/down sell/buy orders
# Current assumption is that current sell/buyqs reflect the size of the running script
running = (callback, defaultSize)->
  totals = []

  (order)->
    amount = parseFloat order.price
    size = order.size or defaultSize
    
    total = size * amount
    total = total * -1.00 if order.side is 'buy'

    totals.push total

    callback
      amount: acct.formatMoney total
      total: acct.formatMoney R.sum totals


module.exports = running
