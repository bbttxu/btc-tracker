require('dotenv').load()
uuid = require 'uuid'
R = require 'ramda'
CoinbaseExchange = require 'coinbase-exchange'

pricing = require './pricing'

authedClient = new CoinbaseExchange.AuthenticatedClient(process.env.API_KEY, process.env.API_SECRET, process.env.API_PASSPHRASE)

package = (options)->
  defaults = ->
    product_id: 'BTC-USD'
    client_oid: uuid.v4()

  order = R.merge defaults, options

  # Ensure data is formatted properly
  order.price = pricing.usd order.price
  order.size = pricing.btc order.size

  order

sell = ( order, callback )->
  client.sell package(order), callback

buy = ( order, callback )->
  client.buy package(order), callback

getOrders = ( callback )->
  client.getOrders callback

module.exports =
  sell: sell
  buy: buy
  orders: getOrders
