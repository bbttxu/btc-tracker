R = require 'ramda'
uuid = require 'uuid'

stream = require './stream'
client = require './client'

SELL_OFFSET = 0.5
USD_PLACES = 2
SPREAD = 1.0

trades = []
sells = []
buys = []
open = []

initiateSell = (price, size = .01)->
  order =
    product_id: 'BTC-USD'
    client_oid: uuid.v4()
    size: size
    # type: 'market'
    cancel_after: 'hour'
    price: price + SELL_OFFSET


  sells.push order.client_oid

  console.log order
  client.sell order, ( err, response )->
    data = JSON.parse response.body
    console.log 'sell', err, R.pick ['price', 'size', 'created_at', 'product_id'], data


handleMatch = (data)->
  trade = R.pick ['price', 'size', 'side', 'time'], data
  # console.log JSON.stringify trade
  price = parseFloat trade.price
  trades.push trade

  prices = R.pluck ['price'], trades
  min = Math.min.apply null, prices
  max = Math.max.apply null, prices
  diff = (max - min).toFixed USD_PLACES
  # console.log min, diff, diff > SPREAD, max, trades.length, price


  if diff > SPREAD
    if max is price
      trades = []
      trades.push price: (price + SPREAD).toFixed USD_PLACES

      initiateSell price

    # We're moving down, so remove the values above top threshold
    if min is price
      aboveThreshold = (val)->
        val.price > ( price + SPREAD )

      trades = R.reject aboveThreshold, trades

handleReceived = (json)->
  if R.contains json.client_oid, sells
    # console.log json
    R.remove json.client_oid, sells
    # buys.push order.client_oid


    open.push json.order_id
    # order =
    #   product_id: 'BTC-USD'
    #   client_oid: uuid.v4()
    #   size: json.size
    #   price: json.price - ( 2 * SPREAD )
    #   cancel_after: 'day'


    # # console.log order
    # client.buy order, ( err, response )->
    #   data = JSON.parse response.body
    #   console.log 'buy', err, R.pick ['price', 'size', 'created_at', 'product_id'], data

  # if R.contains json.client_oid, buys
  #   console.log 'SOLD!', JSON.stringify R.pick ['price', 'size', 'created_at', 'product_id'], json
  #   R.remove json.client_oid, buys

handleDone = (json, size = 0.01)->
  if R.contains json.order_id, open
    # console.log 'handleDone', json
    R.remove json.order_id, open
    order =
      product_id: 'BTC-USD'
      client_oid: uuid.v4()
      size: size
      price: json.price - ( SPREAD + ( 2 * SELL_OFFSET ) )
      cancel_after: 'day'

    # console.log 'handleDone', order
    buys.push order.client_oid

    # console.log order
    client.buy order, ( err, response )->
      data = JSON.parse response.body
      console.log 'buy', err, R.pick ['price', 'size', 'created_at', 'product_id'], data

  # if R.contains json.client_oid, buys
  #   console.log 'SOLD!', JSON.stringify R.pick ['price', 'size', 'created_at', 'product_id'], json
  #   R.remove json.client_oid, buys


stream.on 'open', ->
  stream.send JSON.stringify product_id: 'BTC-USD', type: 'subscribe'

stream.on 'message', (data, flags) ->
  json = JSON.parse data
  # console.log json
  handleMatch json if json.type is 'match' and json.side is 'sell'
  handleReceived json if json.type is 'received'
  handleDone json if json.type is 'done' and json.reason is 'filled'

