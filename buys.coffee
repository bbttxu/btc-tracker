R = require 'ramda'

buys = (price, amount)->

  MIN = 3
  MAX = 5

  start = Math.floor( price * 10 ) * 10

  spread = R.range MIN, MAX + 1

  computeSpread = (value)->
    buyPrice = ( start / 100 ) + ( value ) + ( value / 100 )
    buyOrder =
      size: ( amount / spread.length ).toFixed(8)
      price: ( buyPrice ).toFixed(2)

    buyOrder

  buys = R.map( computeSpread, spread)

  R.reverse R.sort( 'price', buys )

module.exports = buys
