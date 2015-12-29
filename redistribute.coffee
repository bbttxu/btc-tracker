R = require 'ramda'

calculateSell = (data)->
  data.price * data.size

usd = (data)->
  R.sum R.map calculateSell, data

btc = (data)->
  R.sum R.map parseFloat, R.pluck 'size', data

avgUSD = (data)->
  u = usd data
  b = btc data
  u / b

avgBTC = (data)->
  b = btc data
  b / data.length
  # [.01, (a*2-.01)]

equal = (current, average, size)->
  diff = average - current
  max = average + diff
  # console.log current, average, size
  increment = ( max - current ) / ( size + 1 )

  price = (val)->
    price: current + (val * increment)
    n: val

  range = R.range 1, size + 1
  # console.log current, average, increment, range
  console.log R.map price, range





  # a = b / .01

module.exports =
  avgUSD: avgUSD
  avgBTC: avgBTC
  btc: btc
  usd: usd
  equal: equal
