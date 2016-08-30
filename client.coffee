require('dotenv').config({silent: true})
R = require 'ramda'
CoinbaseExchange = require 'coinbase-exchange'

pricing = require './pricing'

authedClient = new CoinbaseExchange.AuthenticatedClient(process.env.API_KEY, process.env.API_SECRET, process.env.API_PASSPHRASE)

parcel = (options)->
  defaults =
    product_id: 'BTC-USD'

  order = R.mergeAll [ defaults, options ]

  # Ensure data is formatted properly
  order.price = pricing.usd order.price
  order.size = pricing.btc order.size

  order

getAccounts = ( callback )->
  authedClient.getAccounts callback

sell = ( order, callback )->
  authedClient.sell parcel(order), callback

buy = ( order, callback )->
  authedClient.buy parcel(order), callback

getOrders = ( callback )->
  authedClient.getOrders callback

withdraw = ( withdrawl, callback )->
  authedClient.withdraw withdrawl, callback

cancelOrder = ( order, callback )->
  authedClient.cancelOrder order, callback

module.exports =
  getAccounts: getAccounts
  sell: sell
  buy: buy
  orders: getOrders
  withdraw: withdraw
  cancelOrder: cancelOrder
