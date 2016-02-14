R = require('ramda')
moment = require('moment')
client = require('./client')

isABuy = (order) ->
  order.side == 'buy'

cancelOrder = (order) ->
  client.cancelOrder order, (err, response) ->
    console.log 'cancel', order, response.body

clearStale = (amount = 3)->
  byPrice = (a, b)->
    a.price > b.price

  client.orders (err, response) ->
    R.map cancelOrder, (R.pluck 'id', R.dropLast amount, (R.sort byPrice, R.filter(isABuy, JSON.parse(response.body))))

clear = ->
  client.orders (err, response) ->
    R.map cancelOrder, R.pluck('id', R.filter(isABuy, JSON.parse(response.body)))

module.exports =
  clear: clear
  stale: clearStale
