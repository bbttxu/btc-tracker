R = require 'ramda'
acct = require 'accounting'

# Show a running total up/down sell/buy orders
# Current assumption is that current sell/buyqs reflect the size of the running script
running = (callback, size)->
  runningAmounts = []

  (order)->
    amount = parseFloat order.price * size
    amount = amount * -1.00 if order.side is 'buy'

    runningAmounts.push amount

    callback amount: amount, total: acct.format R.sum runningAmounts


module.exports = running
