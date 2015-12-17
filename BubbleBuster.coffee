R = require 'ramda'

stream = require './stream'
client = require './client'
pricing = require './pricing'
log = require './logger'


USD_PLACES = 2

openSells = []
openBuys = []
sells = []

isSell = (order)->
  order.side is 'sell'

client.orders (err, response)->
  data = JSON.parse response.body
  sells = R.pluck 'id', R.filter isSell, data

cleanup = (spread, offset, size)->
  console.log "BubbleBuster", spread, offset, size

  prices = []
  buys = []

  initiateSell = (price)->
    order =
      size: size
      cancel_after: 'hour'
      price: price + offset

    openSells.push order.client_oid

    client.sell order, ( err, response )->
      data = JSON.parse response.body
      log data


  handleMatch = (data)->
    trade = R.pick ['price', 'size', 'side', 'time'], data

    price = parseFloat trade.price
    prices.push trade.price

    prices = R.uniq prices

    # current = R.pluck ['price'], prices
    min = Math.min.apply null, prices
    max = Math.max.apply null, prices
    diff = (max - min).toFixed USD_PLACES

    if diff > spread
      if max is price
        prices = []
        prices.push (price + spread).toFixed USD_PLACES

        initiateSell price

      # We're moving down, so remove the values above top threshold
      if min is price
        aboveThreshold = (value)->
          value > ( price + spread )

        prices = R.reject aboveThreshold, prices

  handleReceived = (json)->
    if R.contains json.client_oid, openSells
      R.remove json.client_oid, openSells
      sells.push json.order_id

    if R.contains json.client_oid, openBuys
      R.remove json.client_oid, openBuys
      buys.push json.order_id


  handleFilled = (json)->
    if R.contains json.order_id, sells
      R.remove json.order_id, sells
      log json

      reap = pricing.reapBtc size, json.price - ( spread + ( 2 * offset ) ), json.price

      order =
        size: reap.size
        price: reap.price
        cancel_after: 'day'
        time_in_force: 'GTT'

      openBuys.push order.client_oid

      client.buy order, ( err, response )->
        data = JSON.parse response.body
        log data

    if R.contains json.order_id, buys
      R.remove json.order_id, buys
      log json


  handleCancelled = (json)->
    if R.contains json.order_id, sells
      R.remove json.order_id, sells
      log json

    if R.contains json.order_id, buys
      R.remove json.order_id, buys
      log json


  stream.on 'open', ->
    stream.send JSON.stringify product_id: 'BTC-USD', type: 'subscribe'

  stream.on 'message', (data, flags) ->
    json = JSON.parse data

    handleMatch json if json.type is 'match' and json.side is 'sell'
    handleReceived json if json.type is 'received'
    handleFilled json if json.type is 'done' and json.reason is 'filled'
    handleCancelled json if json.type is 'done' and json.reason is 'cancelled'

module.exports = cleanup
