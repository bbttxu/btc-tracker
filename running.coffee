R = require 'ramda'
acct = require 'accounting'

# Show a running total up/down sell/buy orders
# Current assumption is that current sell/buyqs reflect the size of the running script
running = (callback, defaultSize)->
  totals = []

  isPositive = (order)->
    order > 0

  (order)->
    amount = parseFloat order.price
    size = order.size or defaultSize

    total = size * amount
    total = total * -1.00 if order.side is 'buy'

    totals.push total

    sum = R.sum totals
    up = R.filter isPositive, totals
    down = R.reject isPositive, totals

    callback
      amount: acct.formatMoney total
      total: acct.formatMoney sum
      up: up.length
      down: down.length

module.exports = running
