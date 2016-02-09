R = require('ramda')
moment = require('moment')
client = require('./client')

isABuy = (order) ->
  order.side == 'buy'

cancelOrder = (order) ->
  client.cancelOrder order, (err, response) ->
    console.log 'cancel', order, response.body

clearStale = (amount = 6, span = 'hours')->
  isExpired = (order) ->
    moment(order.created_at).isBefore moment().subtract(amount, span)

  client.orders (err, response) ->
    R.map cancelOrder, R.pluck('id', R.filter(isABuy, R.filter(isExpired, JSON.parse(response.body))))

clear = ->
  client.orders (err, response) ->
    R.map cancelOrder, R.pluck('id', R.filter(isABuy, JSON.parse(response.body)))

module.exports =
  clear: clear
  stale: clearStale
