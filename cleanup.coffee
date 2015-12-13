R = require 'ramda'
uuid = require 'uuid'

stream = require './stream'
client = require './client'
log = require './logger'

USD_PLACES = 2

cleanup = (spread, size, offset)->
  trades = []

  openSells = []
  sells = []
  openBuys = []
  buys = []

  initiateSell = (price)->
    order =
      product_id: 'BTC-USD'
      client_oid: uuid.v4()
      size: size
      cancel_after: 'hour'
      price: price + offset


    openSells.push order.client_oid

    console.log order
    client.sell order, ( err, response )->
      data = JSON.parse response.body
      log.log data
      console.log 'sell', err, R.pick ['price', 'size', 'created_at', 'product_id'], data


  handleMatch = (data)->
    trade = R.pick ['price', 'size', 'side', 'time'], data

    price = parseFloat trade.price
    trades.push trade

    prices = R.pluck ['price'], trades
    min = Math.min.apply null, prices
    max = Math.max.apply null, prices
    diff = (max - min).toFixed USD_PLACES

    if diff > spread
      if max is price
        trades = []
        trades.push price: (price + spread).toFixed USD_PLACES

        initiateSell price

      # We're moving down, so remove the values above top threshold
      if min is price
        aboveThreshold = (val)->
          val.price > ( price + spread )

        trades = R.reject aboveThreshold, trades

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
      log.log json

      order =
        product_id: 'BTC-USD'
        client_oid: uuid.v4()
        size: size
        price: json.price - ( spread + ( 2 * offset ) )
        cancel_after: 'day'

      openBuys.push order.client_oid

      client.buy order, ( err, response )->
        data = JSON.parse response.body
        log.log data
        console.log 'buy', err, R.pick ['price', 'size', 'created_at', 'product_id'], data

    if R.contains json.order_id, buys
      R.remove json.order_id, buys
      log.log json


  handleCancelled = (json)->
    if R.contains json.order_id, sells
      R.remove json.order_id, sells
      log.log json

    if R.contains json.order_id, buys
      R.remove json.order_id, buys
      log.log json


  stream.on 'open', ->
    stream.send JSON.stringify product_id: 'BTC-USD', type: 'subscribe'

  stream.on 'message', (data, flags) ->
    json = JSON.parse data

    handleMatch json if json.type is 'match' and json.side is 'sell'
    handleReceived json if json.type is 'received'
    handleFilled json if json.type is 'done' and json.reason is 'filled'
    handleCancelled json if json.type is 'done' and json.reason is 'cancelled'

module.exports = cleanup
