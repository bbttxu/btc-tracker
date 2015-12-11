R = require 'ramda'

buys = (price, amount, limit)->

  MIN = 1
  MAX = 10

  LOSS = price * 100.0 / 99.75

  start = Math.floor( price * 10 ) * 10

  spread = R.range MIN, MAX + 1

  computeSpread = (value)->
    ( start / 100 ) + ( value ) + ( value / 100 )

  beatTheBreak = (value)->
    LOSS < value

  notOverLimit = (value)->
    value < limit

  prices = R.filter beatTheBreak, R.filter notOverLimit, R.map computeSpread, spread

  price = (value)->
    buyPrice = ( start / 100 ) + ( value ) + ( value / 100 )
    buyOrder =
      size: ( amount / prices.length ).toFixed(8)
      price: value

  buys = R.map price, prices

  R.reverse R.sort( 'price', buys )

module.exports = buys
