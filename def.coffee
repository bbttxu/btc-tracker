R = require 'ramda'
regression = require 'regression'

# convert offer into datapoints for regressions/stats
datapoints = ( order )->
  time = parseFloat order.time
  price = parseFloat order.price

  [ time, price ]


module.exports = ( product_id, side, orders )->
  filterByCurrencyAndSide = ( offer )->
    offer.product_id is product_id and offer.side is side

  currencySide = R.filter filterByCurrencyAndSide, orders

  dataPoints = R.map datapoints, currencySide

  if dataPoints.length > 1
    regress = regression 'linear', dataPoints

    equation = R.reject isNaN, R.filter isFinite, regress.equation

    return equation if equation.length is 2


  undefined
