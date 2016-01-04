R = require 'ramda'

stream = require './stream'
client = require './client'
pricing = require './pricing'
logger = require './logger'

log = (data)->
  console.log 'LongHaul', data
  logger data, 'LongHaul'

USD_PLACES = 2

openBuys = []

isABuy = (order)->
  order.side is 'buy'

client.orders (err, response)->
  data = JSON.parse response.body
  openBuys = R.pluck 'id', R.filter isABuy, data
  console.log openBuys

cleanup = (spread, size)->
  console.log "LongHaul", spread, size

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

    console.log 'take', price, order

    client.buy order, ( err, response )->
      data = JSON.parse response.body
      first.push order.client_oid
      log data


  handleMatch = (data)->
    trade = R.pick ['price', 'size'], data # , 'side', 'time'
    prices.push trade.price

    prices = R.uniq prices

    price = parseFloat trade.price

    max = Math.max.apply null, prices

    breakEven = pricing.buy.breakEven max, spread

    # We're moving down, so remove the values above top threshold
    if price <= breakEven
      take = pricing.buy.take max, spread

      prices = []
      prices.push price

      initiateOne take

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

        makePrice = pricing.buy.make json.price, spread

        order =
          size: size
          price: makePrice
          # cancel_after: 'day'
        console.log json.price, order


        client.sell order, ( err, response )->
          data = JSON.parse response.body
          second.push data.client_oid
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

    handleMatch json if json.type is 'match' and json.side is 'buy'
    handleReceived json if json.type is 'received'
    handleFilled json if json.type is 'done' and json.reason is 'filled'
    # handleCancelled json if json.type is 'done' and json.reason is 'cancelled'

module.exports = cleanup
