R = require('ramda')
moment = require('moment')
client = require('./client')

isABuy = (order) ->
  order.side == 'buy'

isExpired = (order) ->
  moment(order.created_at).isBefore moment().subtract(6, 'hours')

cancelOrder = (order) ->
  client.cancelOrder order, (err, response) ->
    console.log 'cancel', order, response.body

clearStale = ->
  console.log 'clearStale'
  client.orders (err, response) ->
    R.map cancelOrder, R.pluck('id', R.filter(isABuy, R.filter(isExpired, JSON.parse(response.body))))

clear = ->
  client.orders (err, response) ->
    R.map cancelOrder, R.pluck('id', R.filter(isABuy, JSON.parse(response.body)))

  setInterval clearStale, 1000 * 60 * 15

module.exports = clear
