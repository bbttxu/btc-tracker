require('dotenv').config({silent: true})
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
    order.size = pricing.btc order.size, 4

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
        # console.log json.body
        if err
          data = JSON.parse err.body
          console.log 'err', data, order
          reject err

        unless json.body
          console.log 'getAccounts', json
          reject json.body

        data = JSON.parse json.body
        filterCurrency = (account)->
          account.currency is currency

        resolve R.filter filterCurrency, data

      authedClient.getAccounts callback

  sell = ( order, callback )->
    payload = parcel order
    # console.log payload
    authedClient.sell payload, callback

  buy = ( order, callback )->
    payload = parcel order
    # console.log payload
    authedClient.buy payload, callback

  withdraw = ( withdrawl )->
    required =
      coinbase_account_id: process.env.COINBASE_ACCOUNT_ID
      type: 'withdrawl'

    payload = R.mergeAll [withdrawl, required]

    console.log 'withdraw', withdrawl

    new RSVP.Promise (resolve, reject)->
      callback = (err, json)->
        console.log json.body
        reject err if err
        data = JSON.parse json.body
        console.log 'withdraw response', data
        resolve data


      console.log 'withdrawl', payload
      authedClient.withdraw payload, callback

  order = ( order )->
    new RSVP.Promise (resolve, reject)->
      callback = (err, json)->
        if err
          console.log 'error starts here'
          # console.log
          #   err: err
          #   json: json
          #   order: order

          console.log 'error ends here'

          reject
            err: err
            json: json
            order: order

        if json and json.body

          data = JSON.parse json.body
          resolve data

        # console.log 'order', json
        reject
          err: err
          json: json
          order: order

      if order.side is 'buy'
        buy order, callback

      if order.side is 'sell'
        sell order, callback

  delayedOrder = (payload, timeout)->
    new RSVP.Promise (resolve, reject)->

      onGood = (data)->
        # console.log 'onGood', data
        resolve data

      onBad = (data)->
        console.log 'onBad', data
        reject data

      makeOrder = ->
        # console.log payload
        order(payload).then(onGood).catch(onBad)

      setTimeout makeOrder, timeout


  cancelOrder = ( order )->
    new RSVP.Promise (resolve, reject)->
      callback = (err, data)->
        if err
          # data = JSON.parse err.body
          console.log 'err', err, order

        unless data
          console.log 'failed cancel, data:', data
          reject failed: cancelOrder: order

        obj = {}

        payload = JSON.parse data.body
        payload = (JSON.parse data.body).message unless payload is 'OK'
        # payload = 'Found' if order is data.body[0]
        # console.log 'check', order, data.body[0]

        obj.id = order
        obj.message = payload

        resolve obj

      authedClient.cancelOrder order, callback

  delayedCancel = (payload, timeout)->
    new RSVP.Promise (resolve, reject)->

      onGood = (data)->
        resolve data

      onBad = (data)->
        reject data

      curryCancelOrder = ->
        # console.log payload
        cancelOrder(payload).then(onGood).catch(onBad)

      setTimeout curryCancelOrder, timeout



  getFills = (product = product_id)->
    new RSVP.Promise (resolve, reject)->
      authedClient.getFills {product_id: product}, (err, data)->
        if err
          data = JSON.parse err.body
          console.log 'err', data, order

        resolve JSON.parse data.body

  # console.log getFills

  cancelOrders = ->
    new RSVP.Promise (resolve, reject)->
      authedClient.cancelOrders (data)->
        console.log data
        resolve data


  functions =
    stats: stats
    getAccounts: getAccounts
    # sell: sell
    # buy: buy
    # orders: getOrders
    withdraw: withdraw
    cancelOrder: cancelOrder
    delayedCancel: delayedCancel
    order: order
    delayedOrder: delayedOrder
    getFills: getFills
    cancelOrders: cancelOrders
