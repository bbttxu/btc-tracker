uuid = require 'uuid'

require('dotenv').config({silent: true})

CoinbaseExchange = require 'coinbase-exchange'

client = new CoinbaseExchange.AuthenticatedClient(process.env.API_KEY, process.env.API_SECRET, process.env.API_PASSPHRASE)

defaults =
  product_id: 'BTC-USD'
  client_oid: uuid.v4()

sell = ( order, callback )->

  client.sell order, callback

module.exports =
  sell: sell
  buy: buy
