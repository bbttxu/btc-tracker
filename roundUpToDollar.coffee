R = require 'ramda'
RSVP = require 'rsvp'

client = require './client'
orderbook = require './orderBook'


insufficientFunds = 'Insufficient funds'


roundUpToDollar = (order)->
  Math.ceil order.price

promiseToCancelOrder = (id)->
  cancelThis = (resolve, reject)->
    console.log 'client.cancelOrder', id
    callback = (err, data)->
      reject false if err
      console.log data.body

      resolve id


    client.cancelOrder id, callback


  new RSVP.Promise cancelThis


roundedUpOrder = (order)->
  makeOrder = (resolve, reject)->
    callback = (err, json)->
      data = JSON.parse json.body
      console.log data

      if data and (data.message is insufficientFunds)
        console.log 'rejected', JSON.stringify order
        reject -1


      if data and (data.message isnt insufficientFunds)
        console.log 'we did it!', JSON.stringify order
        resolve order


    client.sell order, callback

  new RSVP.Promise makeOrder


consolidateGroups = (value, key, object)->
  ids = R.pluck 'id', value
  cancellations = R.map promiseToCancelOrder, ids

  size = R.sum R.map parseFloat, R.pluck 'size', value

  order =
    size: size
    price: key

  makeNewOrder = roundedUpOrder order

  console.log order

  RSVP.all(cancellations).then (resolvedIds)->
    console.log resolvedIds
    if R.equals( ids, resolvedIds )
      makeNewOrder.then (value)->
        console.log 'madeNewOrder'
        console.log value


processSells = (data)->
  grouped = (R.groupBy roundUpToDollar, data)

  dollarAmounts = R.keys grouped
  console.log R.take 1, dollarAmounts

  # amount = '430'

  # foo = {}
  # foo[amount] = grouped[amount]

  R.mapObjIndexed consolidateGroups, grouped

orderbook.sells processSells
