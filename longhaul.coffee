R = require 'ramda'
uuid = require 'uuid'

stream = require './stream'
client = require './client'
log = require './logger'
pricing = require './pricing'

USD_PLACES = 2

cleanup = (spread, offset, size)->
  trades = []

  first = []
  second = []
  openBuys = []
  openSells = []
  buys = []


  isSell = (order)->
    order.side is 'sell'

  client.getOrders (data)->
    openBuys = R.pluck('id') R.filter isSell, data


  initiateOne = (price)->
    order =
      product_id: 'BTC-USD'
      client_oid: uuid.v4()
      size: size
      cancel_after: 'day'
      price: pricing.usd price

    first.push order.client_oid

    # console.log order
    client.buy order, ( err, response )->
      data = JSON.parse response.body
      log data
      # console.log 'buy order', err, R.pick ['price', 'size', 'created_at', 'product_id'], data


  handleMatch = (data)->
    trade = R.pick ['price', 'size'], data # , 'side', 'time'
    trades.push trade

    price = parseFloat trade.price

    prices = R.pluck ['price'], trades
    min = Math.min.apply null, prices
    max = Math.max.apply null, prices
    diff = (max - min).toFixed USD_PLACES

    if diff > spread
      if max is price
        aboveThreshold = (val)->
          val.price < ( price - spread )

        trades = R.reject aboveThreshold, trades


      # We're moving down, so remove the values above top threshold
      if min is price
        # console.log 'down', price, diff
        trades = []
        trades.push price: ( price - spread )

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

      order =
        product_id: 'BTC-USD'
        client_oid: uuid.v4()
        size: size
        price: pricing.usd ( 1.0025 * json.price ) + ( spread + ( 2 * offset ) )
        # cancel_after: 'day'

      second.push order.client_oid

      client.sell order, ( err, response )->
        data = JSON.parse response.body
        log data
        # console.log 'buy', err, R.pick ['price', 'size', 'created_at', 'product_id'], data

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
