axios = require 'axios'
R = require 'ramda'
RSVP = require 'rsvp'

Client = require './coinbase-public-client'

products = ['BTC-USD', 'ETH-USD', 'ETH-BTC']

promiseStats = (product)->
  new RSVP.Promise (resolve, reject)->
    onSuccess = (response)->
      obj = {}
      obj[product] = response.data
      resolve obj

    onFail = (foo)->
      reject foo

    axios.get("https://api.gdax.com/products/#{product}/stats").then(onSuccess).catch(onFail)


module.exports = ->
  onSuccess = (data)->
    return R.mergeAll data

  onFail = (foo)->
    console.log 'err', foo

  RSVP.all( R.map promiseStats, products ).then(onSuccess).catch(onFail)

