R = require 'ramda'
pricing = require '../pricing'

spreadPrice = (BTCSizeChunk, USDincrementor, options)->
  defaults =
    offset: USDincrementor

  settings = R.mergeAll [ {}, defaults, options ]

  (price, size)->

    # A negative size will fail later, return early with empty array
    return [] if size < 0

    # Ensure a order meets minumum size
    # This is by design—meant to keep trading happening—and might be re-evaluated later
    size = BTCSizeChunk if size < BTCSizeChunk


    # the number of buys needed to satisfy the suggested btc order size
    buys = Math.floor size / BTCSizeChunk
    sizes = R.repeat BTCSizeChunk, buys

    # left over amounts needed to be added to fulfill cumulative order size
    remainder = size % BTCSizeChunk
    sizes[0] = sizes[0] + remainder if sizes[0]

    # Create the orders
    mapIndexed = R.addIndex(R.map)
    getPrices = (orderSize, index)->
      orderPrice = parseFloat(price + settings.offset) + ( ( index ) * USDincrementor )
      order =
        price: pricing.usd orderPrice
        size: pricing.btc orderSize

    mapIndexed getPrices, sizes


module.exports = spreadPrice
