R = require 'ramda'

# Create a structure of BTC sell orders,
# Returns an array of objects with price and size of limit order
buys = (price, amount, limit)->

  MIN = 1
  MAX = 20

  BTC_PLACES = 8

  LOSS = price * 1.0025

  start = Math.floor( price * 10 ) * 10

  spread = R.range MIN, MAX + 1

  isOdd = (n) ->
    n % 2 is 1

  spread = R.filter isOdd, spread

  computeSpread = (value)->
    LOSS * ( 1000 + value ) / 1000

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
    if set.length > 0
      index = Math.floor( Math.random() * set.length )
      maximum = set[index].price * set[index].size
      minimum = price * set[index].size

      average = ( maximum + minimum ) / 2

      set[index].size = ( average / set[index].price ).toFixed BTC_PLACES

    set

  buys = downsample buys

  R.reverse R.sort( 'price', buys )

module.exports = buys
