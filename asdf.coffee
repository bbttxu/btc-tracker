# R = require 'ramda'

# stream = require './stream'

# stream.on 'open', ->
#   stream.send JSON.stringify product_id: 'BTC-USD', type: 'subscribe'

# stream.on 'message', (data, flags) ->
#   json = JSON.parse data
#   console.log JSON.stringify R.pick ['type', 'reason'], json



# orderBook = require './orderbook'

# orderBook.priceAtDollarAmount (err,data)->
#   console.log err

# orderBook.sellBalance console.log

# orderBook.sellBalance (err,data)->
#   console.log err

# orderBook.sellStructure (err,data)->
#   console.log err

# R = require('ramda')
# client = require('./client')

# isABuy = (order) ->
#   order.side == 'buy'


# client.orders (err, response) ->
#   byPrice = (a, b)->
#     a.price > b.price

#   console.log (R.pluck 'id', R.dropLast 3, (R.sort byPrice, R.filter(isABuy, JSON.parse(response.body))))


# R = require 'ramda'
# acct = require 'accounting'
# moment = require 'moment'

# client = require './lib/coinbase-client.coffee'
pricing = require './pricing'

# impact = ( fill )->
#   usd = fill.size * fill.price
#   usd = usd * -1.0 if fill.side is 'buy'
#   usd - fill.fee

# isBuy = ( fill )->
#   fill.side is 'buy'

# add = (a, b)->
#   parseFloat(a) + parseFloat(b)

# describe = (data)->
#   sum =  R.sum R.map impact, data
#   btc = pricing.btc (R.reduce add, 0, R.pluck 'size', data), 3
#   rate = acct.formatMoney pricing.usd ( sum / btc )

#   "#{acct.formatMoney(sum)}, #{btc}btc, #{rate}/btc n:#{data.length}"


# foo = ( data )->
#   buys = R.filter isBuy, data
#   sells = R.reject isBuy, data

#   allTally = describe data
#   sellTally = describe sells
#   buyTally = describe buys

#   earliest = ( R.take 1, (R.pluck 'created_at', data).sort() )[0]
#   since = "since #{moment.utc(earliest).format('YYYY/MM/DD HH:MM')}"

#   console.log [ allTally, buyTally, sellTally, since ].join "\n"

# R = require 'ramda'

# client = require './lib/coinbase-client.coffee'

# foo = require './lib/describeTrades'

# authed = client 'BTC-USD'

# authed.getFills('ETH-USD').then (data)->
#   # console.log R.uniq R.pluck 'product_id', data
#   console.log foo data


# CoinbasePublicClient = require './lib/coinbase-public-client'
CoinbaseAuthClient = require './lib/coinbase-client'

# client = CoinbasePublicClient 'ETH-USD'
auth = CoinbaseAuthClient 'ETH-USD'

# order =
#   size: 0.01
#   price: 11.11
#   side: 'buy'


# auth.order(order).then (data)->
#   console.log data

withdrawl =
  amount: pricing.usd 1
  type: 'withdraw'
  # coinbase_account_id: '82895f2c-fa3e-4664-a338-eb4440aa3db8'
  # coinbase_account_id: '12ce2802-5b83-4eca-a82b-9a48ae4aa2eb'
  # coinbase_account_id: "249a4a26-c2df-4919-8855-a37bfe9dfcd7"
  # coinbase_account_id: 'c3900b27-610e-46e9-bf9b-b817ec454ea1'
  # coinbase_account_id: '66xajak569z4trdyjwlg9o1or'
  # coinbase_account_id: '451fc27f-da13-582a-a407-e92b35d8c9ca'
  # coinbase_account_id: '8b4e64f1-f840-5c56-85a0-72804518f2a2'

onSomething = (data)->
  console.log data


# auth.getAccounts('USD').then(onSomething).catch(onSomething)

auth.withdraw(withdrawl).then(onSomething).catch(onSomething)



# mykey = 'OJW2P9vLDCOD4jLt'
# mysecret = 'QLWVidRbm2YRYEA7oRTu2YFB0qVH40uE'

# Client = require('coinbase').Client
# client = new Client({'apiKey': mykey, 'apiSecret': mysecret})

# client.getAccounts {}, (err, data)->
#   # client.getUser data.id, (err, data)->
#   console.log data
