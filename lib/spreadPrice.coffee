R = require 'ramda'
pricing = require '../pricing'

spreadPrice = (BTCincrementor, USDincrementor)->
  (price, size)->

    # A negative size will fail later, return early with empty array
    return [] if size < 0

    size = 0.01 if size < 0.01


    # the number of buys needed to satisfy the suggested btc order size
    buys = Math.floor size / BTCincrementor
    sizes = R.repeat BTCincrementor, buys

    # left over amounts needed to be added to fulfill cumulative order size
    remainder = size % BTCincrementor
    sizes[0] = sizes[0] + remainder if sizes[0]

    # Create the orders
    mapIndexed = R.addIndex(R.map)
    getPrices = (orderSize, index)->
      orderPrice = parseFloat(price) + ( ( index + 1 ) * USDincrementor )
      order =
        price: pricing.usd orderPrice
        size: pricing.btc orderSize

    mapIndexed getPrices, sizes


module.exports = spreadPrice
