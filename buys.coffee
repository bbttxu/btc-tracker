R = require 'ramda'

# Create a structure of BTC sell orders,
# Returns an array of objects with price and size of limit order
buys = (price, amount, limit)->

  MIN = 1
  MAX = 10

  BTC_PLACES = 7

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

  priceBuys = (value)->
    buyPrice = ( start / 100 ) + ( value ) + ( value / 100 )
    buyOrder =
      size: ( amount / prices.length ).toFixed BTC_PLACES
      price: value.toFixed(2)

  buys = R.map priceBuys, prices

  downsample = (set)->
    index = Math.floor( Math.random() * set.length )
    maximum = set[index].price * set[index].size
    minimum = price * set[index].size

    average = ( maximum + minimum ) / 2

    set[index].size = ( average / set[index].price ).toFixed BTC_PLACES

    set

  buys = downsample buys

  R.reverse R.sort( 'price', buys )

module.exports = buys
