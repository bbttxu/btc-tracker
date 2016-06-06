# fixedInvestment.coffee

# The purpose of this script is to
# 1. maintain X number of BTC valued at the provided USD investment
# 2. use provided USD reserve to purchase more BTC to maintain that provided USD investment should the value fall
# 3. recoup provided USD payout once the provided investment and reserve have returned to initial values

R = require 'ramda'
RSVP = require 'rsvp'
# td = require 'throttle-debounce'
# acct = require 'accounting'
moment = require 'moment'

# {pricing} = require './defaults'
stream = require './stream'
client = require './lib/coinbase-client'
pricing = require './pricing'

BuyStructure = require './lib/buyStructure'
SellStructure = require './lib/sellStructure'

matchCurrency = (currency)->
  (account)->
    account.currency is currency

isUSD = matchCurrency 'USD'
isBTC = matchCurrency 'BTC'

orders = []

getCurrentOrders = ->
  # console.log 'getCurrentOrders', orders
  new RSVP.Promise ( resolve, reject )->
    resolve orders


cancelPreviousOrders = (orders)->
  # console.log 'cancelPreviousOrders', orders
  new RSVP.Promise (resolve, reject)->

    onThen = (data)->
      # console.log 'onThen', data
      resolve data

    onError = (data)->
      reject data

    RSVP.all( R.map client.cancelOrder, orders ).then( onThen ).catch( onError )


removeCurrentOrders = (orders)->
  # console.log 'removeCurrentOrders', orders
  new RSVP.Promise ( resolve, reject )->

    alreadyDone = (order)->
      order.message is 'Order already done' or order.message is 'OK'

    resolve R.pluck 'id', R.reject alreadyDone, orders


holdoverQuestionableOrders = (uncertain)->
  # console.log 'holdoverQuestionableOrders', uncertain.length
  new RSVP.Promise (resolve, reject)->
    orders = uncertain
    resolve uncertain



fixedInvestment = (investment, reserve, payout, pricingOptions = {}, minutes = 60)->

  # pricingSettings = R.mergeAll [ pricing, pricingOptions ]

  buyStructure = BuyStructure pricingOptions
  sellStructure = SellStructure pricingOptions


  console.log "#{moment().format()} Maintaining #{investment} with #{reserve} reserve and payouts at #{payout}"

  prices = {}
  updatePrices = (data)->
    prices = R.merge prices, data

  # openOrders = []

  update = ->
    # Pay yourself
    payYourself = (bar)->
      new RSVP.Promise (resolve, reject)->
        foo = client.getAccounts('USD')

        foo.then (accounts)->
          account = accounts[0]

          take = account.balance - ( reserve + payout )


          if take > 0
            withdrawl =
              coinbase_account_id: account.id
              amount: pricing.usd 1

            asdf = client.withdraw( withdrawl )

            asdf.then (value)->
              resolve bar
           else
             resolve 'stay poor'

    getStats = (bar)->
      # console.log 'getStats'
      new RSVP.Promise (resolve, reject)->

        onThen = (value)->
          resolve value

        onCatch = (value)->
          reject value

        client.stats().then(onThen).catch(onCatch)


    # Determine your position
    determinePosition = (stats)->
      console.log JSON.stringify(stats), 'determinePosition'
      new RSVP.Promise (resolve, reject)->

        determine = (data)->
          # console.log 'determine', data
          btc = (R.filter isBTC, data)[0]

          # sellPrice = prices.sellBid or stats.high
          sellPrice = stats.high
          if prices.sell
            sellPrice = prices.sell

          buyPrice = stats.low
          if prices.buy
            buyPrice = prices.buy
            # if prices.buy >= stats.open
            #   buyPrice = stats.low

          bids = []

          sell = btc.available * sellPrice
          sellBTC = ( sell - investment ) / sellPrice
          bids.push sellStructure sellPrice, sellBTC if sellPrice and sellBTC > 0

          buy = btc.available * buyPrice
          buyBTC = ( investment - buy ) / buyPrice
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

        RSVP.all(newOrders).then (result)->
          orders = orders.concat R.pluck 'id', result
          resolve orders

    # Error handling
    onError = (error)->
      console.log 'onError', error

    getCurrentOrders()
      .then(cancelPreviousOrders)
      .then(removeCurrentOrders)
      .then(holdoverQuestionableOrders)
      .then(payYourself)
      .then(getStats)
      .then(determinePosition)
      .then(placeNewOrders)
      .catch(onError)


  setInterval update, 1000 * 60 * minutes
  update()

  stream.on 'open', ->
    stream.send JSON.stringify product_id: 'BTC-USD', type: 'subscribe'

  stream.on 'message', (data, flags) ->
    json = JSON.parse data
    if json.type is 'match'
      price = parseFloat json.price
      obj = {}
      obj[json.side] = price
      updatePrices obj

    # if json.type is 'received'
    #   if R.contains json.order_id, orders
    #     console.log 'received', JSON.stringify json

    if json.type is 'filled'
      if R.contains json.order_id, orders
        console.log 'filled', JSON.stringify json


module.exports = fixedInvestment
