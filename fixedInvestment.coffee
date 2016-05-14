# fixedInvestment.coffee

# The purpose of this script is to
# 1. maintain X number of BTC valued at the provided USD investment
# 2. use provided USD reserve to purchase more BTC to maintain that provided USD investment should the value fall
# 3. recoup provided USD payout once the provided investment and reserve have returned to initial values


R = require 'ramda'
RSVP = require 'rsvp'
# td = require 'throttle-debounce'
acct = require 'accounting'
moment = require 'moment'

stream = require './stream'
client = require './lib/coinbase-client'
pricing = require './pricing'
spreader = require './lib/spreadPrice'

matchCurrency = (currency)->
  (account)->
    account.currency is currency

isUSD = matchCurrency 'USD'
isBTC = matchCurrency 'BTC'


fixedInvestment = (investment, reserve, payout, offset = 0.99, minutes = 60)->
  console.log "#{moment().format()} Maintaining #{investment} with #{reserve} reserve and payouts at #{payout}"

  prices = {}
  updatePrices = (data)->
    prices = R.merge prices, data

  openOrders = []
  orders = []

  update = ->
    cancelOrder = (id)->
      client.cancelOrder id

    cancelPreviousOrders = R.map cancelOrder, orders

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
      console.log JSON.stringify stats, 'determinePosition'
      new RSVP.Promise (resolve, reject)->

        determine = (data)->
          # console.log 'determine', data
          btc = (R.filter isBTC, data)[0]

          # sellPrice = prices.sellBid or stats.high
          sellPrice = stats.high

          buyPrice = stats.low
          if prices.buyBid and prices.buyBid < stats.open
            buyPrice = prices.buyBid

          sell = btc.available * sellPrice
          buy = btc.available * buyPrice

          sellBTC = ( sell - investment ) / sellPrice
          buyBTC = ( investment - buy ) / buyPrice

          bids = []

          if sellPrice and sellBTC > 0
            gap = ( btc.available * sellPrice ) - investment
            console.log "#{moment().format()} We'd want to sell #{acct.formatMoney(gap)} worth of BTC at #{acct.formatMoney(sellPrice)}/BTC, or #{pricing.btc(sellBTC)}BTC"
            sellSpread = spreader 0.01, offset
            sideSell = (order)->
              R.merge side: 'sell', order

            bids.push R.map sideSell, sellSpread sellPrice, sellBTC

          if buyPrice and buyBTC > 0
            gap = investment - ( btc.available * buyPrice )
            console.log "#{moment().format()} We'd want to buy #{acct.formatMoney(gap)} worth of BTC at #{acct.formatMoney(buyPrice)}/BTC, or #{pricing.btc(buyBTC)}BTC"
            buySpread = spreader 0.01, ( -1.0 * offset )
            sideBuy = (order)->
              R.merge side: 'buy', order

            bids.push R.map sideBuy, buySpread buyPrice, buyBTC
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

    RSVP.all(cancelPreviousOrders).then(payYourself).then(getStats).then(determinePosition).then(placeNewOrders).catch(onError)


  setTimeout update, 1000 * 60
  setInterval update, 1000 * 60 * minutes

  stream.on 'open', ->
    stream.send JSON.stringify product_id: 'BTC-USD', type: 'subscribe'

  stream.on 'message', (data, flags) ->
    json = JSON.parse data
    if json.type is 'match'
      upDown = offset * -1 if json.side is 'buy'
      price = parseFloat json.price
      bidPrice = price + upDown
      obj = {}
      obj[json.side] = price
      obj[json.side + 'Bid'] = bidPrice
      updatePrices obj

    # if json.type is 'received'
    #   if R.contains json.order_id, orders
    #     console.log 'received', JSON.stringify json

    if json.type is 'filled'
      if R.contains json.order_id, orders
        console.log 'filled', JSON.stringify json


module.exports = fixedInvestment
