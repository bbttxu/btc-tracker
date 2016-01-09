R = require 'ramda'

client = require './client'

isABuy = (order)->
  order.side is 'buy'

cancelOrder = (order)->
  client.cancelOrder order, (err, response)->
    console.log 'cancel', order, response.body

clear = ->
  client.orders (err, response)->
    R.map cancelOrder, R.pluck 'id', R.filter isABuy, JSON.parse response.body

module.exports = clear
