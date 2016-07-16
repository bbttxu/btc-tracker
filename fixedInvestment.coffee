# fixedInvestment.coffee

# The purpose of this script is to
# 1. maintain X number of product valued at the provided USD investment
# 2. use available USD reserve to purchase more product to maintain that provided USD investment should the value fall

R = require 'ramda'
RSVP = require 'rsvp'
moment = require 'moment'

stream = require './lib/stream'
coinbaseClient = require './lib/coinbase-client'
coinbasePublicClient = require './lib/coinbase-public-client'
pricing = require './pricing'
logger = require './lib/logger'
notify = require './notification'

BuyStructure = require './lib/buyStructure'
SellStructure = require './lib/sellStructure'

ProcessFills = require './lib/saveFills'

matchCurrency = (currency)->
  (account)->
    account.currency is currency


fixedInvestment = (product = 'BTC-USD', investment, pricingOptions = {}, minutes = 60)->
  orders = []

  pricingSettings = R.mergeAll [ {}, pricingOptions, { product: product } ]

  productStream = stream(product)
  client = coinbaseClient(product)
  unauth = coinbasePublicClient product
  processFills = ProcessFills product
  log = logger product

  buyStructure = BuyStructure pricingSettings
  sellStructure = SellStructure pricingSettings



  log "Maintaining #{investment} in #{product}"

  prices = {}
  updatePrices = (data)->
    prices = R.merge prices, data

  isProduct = matchCurrency product.split('-')[0]

  getCurrentOrders = ->
    console.log 'getCurrentOrders', orders
    new RSVP.Promise ( resolve, reject )->
      resolve orders


  cancelPreviousOrders = (orders)->
    console.log 'cancelPreviousOrders', orders
    new RSVP.Promise (resolve, reject)->

      onThen = (data)->
        # console.log 'onThen', data
        resolve data

      onError = (data)->
        reject data

      RSVP.all( R.map client.cancelOrder, orders ).then( onThen ).catch( onError )


  removeCurrentOrders = (orders)->
    console.log 'removeCurrentOrders', orders
    new RSVP.Promise ( resolve, reject )->

      alreadyDone = (order)->
        order.message is 'Order already done' or order.message is 'NotFound' or order.message is 'OK'

      resolve R.pluck 'id', R.reject alreadyDone, orders


  holdoverQuestionableOrders = (uncertain)->
    console.log 'holdoverQuestionableOrders', uncertain.length
    new RSVP.Promise (resolve, reject)->
      orders = uncertain
      resolve uncertain


  update = ->
    # Pay yourself
    payYourself = (bar)->
      new RSVP.Promise (resolve, reject)->
        resolve 'stay poor'

    getStats = (bar)->
      # console.log 'getStats'
      new RSVP.Promise (resolve, reject)->

        onThen = (value)->
          resolve value

        onCatch = (value)->
          reject value

        unauth.stats().then(onThen).catch(onCatch)


    # Determine your position
    determinePosition = (stats)->
      log JSON.stringify(stats), 'determinePosition'
      new RSVP.Promise (resolve, reject)->

        determine = (data)->
          # console.log 'determine', data
          btc = (R.filter isProduct, data)[0]

          volumeDiff = ( stats.volume * 30.0 ) / stats.volume_30day

          volumeAdjustment = 1.0
          if volumeDiff > 1.0
            volumeAdjustment = volumeDiff
            log "volume adjustment", volumeDiff


          sellPrice = stats.high
          # sellPrice = R.max stats.open, prices.sell if prices.sell
          if prices.sell
            # FIXME TODO create average value function
            open = parseFloat stats.open
            low = parseFloat stats.low
            mid = pricing.usd((open + low) / 2.0)
            # console.log mid, open, low, prices.sell, 'sell'
            sellPrice = R.max mid, prices.sell

          buyPrice = stats.low
          # buyPrice = R.min stats.open, prices.buy if prices.buy
          if prices.buy
            # FIXME TODO create average value function
            open = parseFloat stats.open
            high = parseFloat stats.high
            mid = pricing.usd((open + high) / 2.0)
            # console.log mid, open, high, prices.buy, 'buy'
            buyPrice = R.min mid, prices.buy


          bids = []

          sell = btc.available * sellPrice
          sellBTC = ( ( sell - investment ) / sellPrice ) * volumeAdjustment
          bids.push sellStructure sellPrice, sellBTC if sellPrice and sellBTC > 0

          buy = btc.available * buyPrice
          buyBTC = ( ( investment - buy ) / buyPrice ) * volumeAdjustment
          bids.push buyStructure buyPrice, buyBTC if buyPrice and buyBTC > 0

          resolve R.flatten bids

        client.getAccounts().then determine

    # Execute new Position
    placeNewOrders = (data)->
      # console.log data, 'placeNewOrders'
      new RSVP.Promise (resolve, reject)->
        makeOrder = (order)->
          client.order order


        newOrders = R.map makeOrder, R.flatten data

        RSVP.allSettled(newOrders).then (result)->
          fulfilled = R.pluck 'value', R.filter R.propEq('state', 'fulfilled'), result
          orders = orders.concat R.reject R.isNil, R.pluck 'id', fulfilled
          resolve orders

    # Error handling
    onError = (error)->
      console.log 'onError', error

    getCurrentOrders()
      .then(cancelPreviousOrders)
      .then(removeCurrentOrders)
      .then(holdoverQuestionableOrders)
      # .then(payYourself)
      .then(getStats)
      .then(determinePosition)
      .then(placeNewOrders)
      .catch(onError)


  setInterval update, 1000 * 60 * minutes
  update()


  productStream.on 'message', (json, flags) ->
    if json.type is 'match'
      price = parseFloat json.price
      obj = {}
      obj[json.side] = price
      updatePrices obj

    if json.type is 'filled'
      if R.contains json.order_id, orders
        log 'filled', JSON.stringify json
        processFills()

module.exports = fixedInvestment
