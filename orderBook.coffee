R = require 'ramda'
acct = require 'accounting'

client = require './client'

isABuy = (order)->
  order.side is 'buy'

originalPrice = (price)->
  decrement = price.toString().split('.')[1].substring(1,2)
  price - decrement - ( decrement / 100 )

calculateBuy = (data)->
  data.size * originalPrice data.price

buys = (callback)->
  client.orders (err,response)->
    data = JSON.parse response.body
    callback  R.filter isABuy, data

usdBuys = (callback)->
  buys (response)->
    callback R.sum R.map calculateBuy, response

btcBuys = (callback)->
  buys (response)->
    callback R.sum R.map parseFloat, R.pluck 'size', response


isASell = (order)->
  order.side is 'sell'

calculateSell = (data)->
  data.price * data.size

sells = (callback)->
  client.orders (err,response)->
    data = JSON.parse response.body
    # console.log 'sells'
    callback R.filter isASell, data

usdSells = (callback)->
  sells (response)->
    callback R.sum R.map calculateSell, response

btcSells = (callback)->
  sells (response)->
    callback R.sum R.map parseFloat, R.pluck 'size', response


buyBalance = (callback)->
  usdBuys (usd)->
    btcBuys (btc)->
      buys =
        usd: acct.formatMoney usd
        btc: btc
        avg: acct.formatMoney usd / btc
      callback 'buys', buys

sellBalance = (callback)->
  usdSells (usd)->
    btcSells (btc)->
      callback
        usd: acct.formatMoney usd
        btc: btc
        avg: acct.formatMoney usd / btc

sellStructure = (callback)->
  sells (response)->
    # console.log JSON.stringify response

    round = (acc,val)->
      price = Math.round val.price
      size = parseFloat val.size
      # console.log price
      if acc[price]
        acc[price] = acc[price] + size

      unless acc[price]
        acc[price] = size

      # console.log acc
      acc

    callback R.reduce( round, {}, (R.map (R.pick ['price', 'size']), response) )


# buyBalance console.log
# sellBalance console.log
# sellStructure console.log

module.exports =
  # orders: orders
  buys: buys
  sells: sells
  sellBalance: sellBalance
  sellStructure: sellStructure
