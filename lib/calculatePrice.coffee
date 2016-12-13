R = require 'ramda'

module.exports = (stats)->
  return undefined unless stats.side is 'buy' or stats.side is 'sell'

  price = stats.price
  price = R.max price, stats.open if stats.side is 'sell'
  price = R.min price, stats.open if stats.side is 'buy'

  decision = R.mergeAll [stats, price: price]

