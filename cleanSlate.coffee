R = require 'ramda'
moment = require 'moment'

client = require './client'
pricing = require './pricing'

isABuy = (order) ->
  order.side == 'buy'

cancelOrder = (order) ->
  client.cancelOrder order, (err, response) ->
    console.log 'cancel', order, response.body

clearStale = (size, amount = 1)->
  byPrice = (a, b)->
    a.price > b.price

  isRightSize = (a)->
    pricing.btc(size) is a.size

  client.orders (err, response) ->
    ordersBySize = R.sort byPrice, R.filter(isRightSize, R.filter(isABuy, JSON.parse(response.body)))
    allButTheLast = R.dropLast amount, ordersBySize
    R.map cancelOrder, R.pluck 'id', allButTheLast

clear = ->
  client.orders (err, response) ->
    R.map cancelOrder, R.pluck('id', R.filter(isABuy, JSON.parse(response.body)))

module.exports =
  clear: clear
  stale: clearStale
