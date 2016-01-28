R = require 'ramda'
uuid = require 'uuid'

stream = require './stream'
client = require './client'
pricing = require './pricing'
logger = require './logger'

cleanup = (spread, size)->
  log = (data)->
    logger data, "LongHaul-#{spread}-#{size}"

  logOrder = (data)->
    log JSON.stringify R.pick ['id','size','price', 'side', 'message', 'type', 'reason'], data

  log 'starting...'

  prices = []
  openBuys = []

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
      client_oid: uuid.v4()

    first.push order.client_oid

    client.buy order, ( err, response )->
      data = JSON.parse response.body
      logOrder data
      # console.log 'first', first


  handleMatch = (data)->
    trade = R.pick ['price', 'size'], data # , 'side', 'time'
    prices.push trade.price

    prices = R.uniq prices

    price = parseFloat trade.price

    max = Math.max.apply null, prices

    take = pricing.buy.take max, spread

    # We're moving down, so remove the values above top threshold
    if price <= take
      takeEven = pricing.buy.takeEven max, spread

      prices = []
      prices.push price

      initiateOne takeEven

  handleReceived = (json)->
    if R.contains json.client_oid, first
      R.remove json.client_oid, first
      openBuys.push json.order_id
      # console.log 'openBuys', openBuys

    if R.contains json.client_oid, second
      R.remove json.client_oid, second
      openSells.push json.order_id

  handleFilled = (json)->
    if R.contains json.order_id, openBuys
      R.remove json.order_id, openBuys

      # We don't receive size (only `remaining_size`, usually zero at these sizes), so assume the price it was bought at?
      console.log 'buy', ( parseFloat(json.price) * parseFloat(size) * -1 ), json.price * size * -1
      logOrder json


      # TODO investigate why this isn't defined sometimes
      if json.price

        makePrice = pricing.buy.make json.price, spread

        order =
          size: size
          price: makePrice
          client_oid: uuid.v4()
          # cancel_after: 'day'

        second.push order.client_oid

        client.sell order, ( err, response )->
          data = JSON.parse response.body
          logOrder data

    if R.contains json.order_id, openSells
      R.remove json.order_id, openSells

      # We don't receive size (only `remaining_size`, usually zero at these sizes), so assume the price it was bought at?
      console.log 'sell', parseFloat(json.price) * parseFloat(size)
      logOrder json


  handleCancelled = (json)->
    if R.contains json.order_id, openBuys
      R.remove json.order_id, openBuys
      logOrder json

    if R.contains json.order_id, openSells
      R.remove json.order_id, openSells
      logOrder json


  stream.on 'open', ->
    stream.send JSON.stringify product_id: 'BTC-USD', type: 'subscribe'

  stream.on 'message', (data, flags) ->
    json = JSON.parse data

    handleMatch json if json.type is 'match' and json.side is 'buy'
    handleReceived json if json.type is 'received'
    handleFilled json if json.type is 'done' and json.reason is 'filled'
    # handleCancelled json if json.type is 'done' and json.reason is 'cancelled'

module.exports = cleanup
