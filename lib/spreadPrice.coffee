R = require 'ramda'
pricing = require '../pricing'

spreadPrice = (BTCincrementor, USDincrementor)->
  # console.log 'a', BTCincrementor, USDincrementor
  (price, size)->
    # console.log 'b', price, size

    # the number of buys needed to satisfy the suggested btc order size
    buys = Math.floor size / BTCincrementor
    sizes = R.repeat BTCincrementor, buys

    # left over amounts needed to be added to fulfill cumulative order size
    remainder = size % BTCincrementor
    sizes[0] = sizes[0] + remainder if sizes[0]

    # Create the orders
    mapIndexed = R.addIndex(R.map)
    getPrices = (orderSize, index)->
      # console.log orderSize, index
      orderPrice = parseFloat(price) + ( index * USDincrementor )
      order =
        price: pricing.usd orderPrice
        size: pricing.btc orderSize

    mapIndexed getPrices, sizes

module.exports = spreadPrice
