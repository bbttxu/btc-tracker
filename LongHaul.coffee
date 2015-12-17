R = require 'ramda'

stream = require './stream'
client = require './client'
log = require './logger'

USD_PLACES = 2

cleanup = (spread, offset, size)->
  console.log "LongHaul", spread, offset, size

  prices = []

  first = []
  second = []
  openBuys = []
  openSells = []
  buys = []

  initiateOne = (price)->
    order =
      size: size
      cancel_after: 'day'
      price: price

    first.push order.client_oid

    client.buy order, ( err, response )->
      data = JSON.parse response.body
      log data


  handleMatch = (data)->
    trade = R.pick ['price', 'size'], data # , 'side', 'time'
    prices.push trade.price

    prices = R.uniq prices

    # console.log prices

    price = parseFloat trade.price

    # current = R.pluck ['price'], prices
    min = Math.min.apply null, prices
    max = Math.max.apply null, prices
    diff = (max - min).toFixed USD_PLACES

    if diff > spread
      if max is price
        aboveThreshold = (value)->
          value < ( price - spread )

        prices = R.reject aboveThreshold, prices


      # We're moving down, so remove the values above top threshold
      if min is price
        prices = []
        prices.push ( price - spread )

        initiateOne ( price - offset ), diff

  handleReceived = (json)->
    if R.contains json.client_oid, first
      R.remove json.client_oid, first
      openBuys.push json.order_id

    if R.contains json.client_oid, second
      R.remove json.client_oid, second
      openSells.push json.order_id

  handleFilled = (json)->
    if R.contains json.order_id, openBuys
      R.remove json.order_id, openBuys
      log json

      # TODO investigate why this isn't defined sometimes
      if json.price
        order =
          size: size
          price: ( 1.0025 * json.price ) + ( spread + ( 2 * offset ) )
          # cancel_after: 'day'

        second.push order.client_oid

        client.sell order, ( err, response )->
          data = JSON.parse response.body
          log data

    if R.contains json.order_id, openSells
      R.remove json.order_id, openSells
      log json


  handleCancelled = (json)->
    if R.contains json.order_id, openBuys
      R.remove json.order_id, openBuys
      log json

    if R.contains json.order_id, openSells
      R.remove json.order_id, openSells
      log json


  stream.on 'open', ->
    stream.send JSON.stringify product_id: 'BTC-USD', type: 'subscribe'

  stream.on 'message', (data, flags) ->
    json = JSON.parse data

    handleMatch json if json.type is 'match' and json.side is 'sell'
    handleReceived json if json.type is 'received'
    handleFilled json if json.type is 'done' and json.reason is 'filled'
    # handleCancelled json if json.type is 'done' and json.reason is 'cancelled'

module.exports = cleanup
