# R = require 'ramda'

# stream = require './stream'

# stream.on 'open', ->
#   stream.send JSON.stringify product_id: 'BTC-USD', type: 'subscribe'

# stream.on 'message', (data, flags) ->
#   json = JSON.parse data
#   console.log JSON.stringify R.pick ['type', 'reason'], json



orderBook = require './orderbook'

# orderBook.priceAtDollarAmount (err,data)->
#   console.log err

# orderBook.sellBalance console.log

orderBook.sellBalance (err,data)->
  console.log err

orderBook.sellStructure (err,data)->
  console.log err

# R = require('ramda')
# client = require('./client')

# isABuy = (order) ->
#   order.side == 'buy'


# client.orders (err, response) ->
#   byPrice = (a, b)->
#     a.price > b.price

#   console.log (R.pluck 'id', R.dropLast 3, (R.sort byPrice, R.filter(isABuy, JSON.parse(response.body))))
