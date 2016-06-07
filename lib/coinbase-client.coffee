require('dotenv').load()
R = require 'ramda'
RSVP = require 'rsvp'
CoinbaseExchange = require 'coinbase-exchange'

pricing = require '../pricing'

authedClient = new CoinbaseExchange.AuthenticatedClient(process.env.API_KEY, process.env.API_SECRET, process.env.API_PASSPHRASE)

module.exports = (product_id)->
  parcel = (options)->
    defaults =
      product_id: product_id

    order = R.mergeAll [ defaults, options ]

    # Ensure data is formatted properly
    order.price = pricing.usd order.price
    order.size = pricing.btc order.size

    order


  stats = (currency = product_id)->
    new RSVP.Promise (resolve, reject)->
      callback = (err, json)->
        if err
          reject err

        resolve JSON.parse json.body

      authedClient.getProduct24HrStats callback

  getAccounts = ()->
    currency = product_id.split('-')[0]
    new RSVP.Promise (resolve, reject)->
      callback = (err, json)->
        # console.log json
        if err
          data = JSON.parse err.body
          console.log 'err', data, order
          reject err

        data = JSON.parse json.body
        filterCurrency = (account)->
          account.currency is currency

        resolve R.filter filterCurrency, data

      authedClient.getAccounts callback

  sell = ( order, callback )->
    authedClient.sell parcel(order), callback

  buy = ( order, callback )->
    authedClient.buy parcel(order), callback

  # getOrders = ( callback )->
  #   authedClient.getOrders callback

  # withdraw = ( withdrawl, callback )->
  #   authedClient.withdraw withdrawl, callback

  withdraw = ( withdrawl )->
    # authedClient.withdraw withdrawl, callback
    new RSVP.Promise (resolve, reject)->
      callback = (err, json)->
        reject err if err
        data = JSON.parse json.body
        console.log 'withdraw response', data
        resolve data

      authedClient.withdraw withdrawl, callback

  order = ( order )->
    new RSVP.Promise (resolve, reject)->
      callback = (err, json)->
        reject err if err
        data = JSON.parse json.body
        resolve data

      if order.side is 'buy'
        buy order, callback

      if order.side is 'sell'
        sell order, callback


  cancelOrder = ( order )->
    new RSVP.Promise (resolve, reject)->
      callback = (err, data)->
        if err
          data = JSON.parse err.body
          console.log 'err', data, order

        obj = {}
        payload = data.body
        payload = (JSON.parse data.body).message unless payload is 'OK'

        obj.id = order
        obj.message = payload
        resolve obj

      authedClient.cancelOrder order, callback

  getFills = ->
    new RSVP.Promise (resolve, reject)->
      authedClient.getFills (err, data)->
        if err
          data = JSON.parse err.body
          console.log 'err', data, order

        resolve JSON.parse data.body

  functions =
    stats: stats
    getAccounts: getAccounts
    # sell: sell
    # buy: buy
    # orders: getOrders
    withdraw: withdraw
    cancelOrder: cancelOrder
    order: order
    getFills: getFills
