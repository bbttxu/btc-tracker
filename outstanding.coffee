R = require 'ramda'
# client = require './client'
acct = require 'accounting'

orderBook = require './orderBook'

# openOrders = (current)->

#   originalPrice = (price)->
#     decrement = price.toString().split('.')[1].substring(1,2)
#     price - decrement - ( decrement / 100 )

#   calculateBuy = (data)->
#     data.size * originalPrice data.price

#   calculateSell = (data)->
#     data.price * data.size

#   calculateBailing = (data)->
#     data.size * current

#   analyzeOrders = (err, response)->
#     data = JSON.parse response.body


#     isSell = (order)->
#       order.side is 'sell'

#     isBuy = (order)->
#       order.side is 'buy'

#     # console.log R.pluck('id') R.filter isBuy, data
#     # console.log R.pluck('id') R.filter isSell, data

#     console.log 'bought', acct.formatMoney R.sum R.map calculateBuy, R.filter isBuy, data
#     console.log 'sell', acct.formatMoney R.sum R.map calculateSell, R.filter isSell, data
#     console.log 'bail', acct.formatMoney R.sum R.map calculateBailing, R.filter isSell, data
#     # console.log data


#   client.getOrders analyzeOrders


# openOrders '444.75'

orderBook.buys console.log
