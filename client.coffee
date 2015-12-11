# client.coffee

require('dotenv').load()

CoinbaseExchange = require 'coinbase-exchange'

authedClient = new CoinbaseExchange.AuthenticatedClient(process.env.API_KEY, process.env.API_SECRET, process.env.API_PASSPHRASE)

module.exports = authedClient
