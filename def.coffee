R = require 'ramda'
regression = require 'regression'
moment = require 'moment'

# convert offer into datapoints for regressions/stats
datapoints = ( order )->
  time = parseFloat order.time
  price = parseFloat order.price

  [ time, price ]


module.exports = ( product_id, side, duration, orders )->
  cutOff = moment().subtract( duration, 's' )

  tooOld = ( offer )->
    moment( offer.time ).isBefore cutOff

  filterByCurrencyAndSide = ( offer )->
    offer.product_id is product_id and offer.side is side

  currencySide = R.filter filterByCurrencyAndSide, R.reject tooOld, orders

  dataPoints = R.map datapoints, currencySide

  # Only do a regression if there are two or more points
  if dataPoints.length > 1
    regress = regression 'linear', dataPoints

    equation = R.reject isNaN, R.filter isFinite, regress.equation

    console.log equation

    return equation if equation.length is 2


  undefined
