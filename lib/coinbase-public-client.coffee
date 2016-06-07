CoinbaseExchange = require 'coinbase-exchange'
RSVP = require 'rsvp'

module.exports = (product_id)->
  publicClient = new CoinbaseExchange.PublicClient product_id

  stats = ->
    new RSVP.Promise (resolve, reject)->
      callback = (err, json)->
        if err
          reject err

        resolve JSON.parse json.body

      publicClient.getProduct24HrStats callback

  publicFunctions =
    stats: stats

