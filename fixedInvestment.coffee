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


fixedInvestment = (investment, reserve, payout)->
  console.log "#{moment().format()} Maintaining #{investment} with #{reserve} reserve and payouts at #{payout}"

  offset = 0.33

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


    # Determine your position
    determinePosition = (foo)->
      console.log 'determinePosition'
      new RSVP.Promise (resolve, reject)->

        determine = (data)->
          btc = (R.filter isBTC, data)[0]

          sell = btc.available * prices.sellBid
          buy = btc.available * prices.buyBid

          sellBTC = ( sell - investment ) / prices.sellBid
          buyBTC = ( investment - buy ) / prices.buyBid


          bids = []

          if prices.sellBid and sellBTC > 0
            gap = ( btc.available * prices.sellBid ) - investment
            console.log "#{moment().format()} We'd want to sell #{acct.formatMoney(gap)} worth of BTC at #{acct.formatMoney(prices.sellBid)}/BTC, or #{pricing.btc(sellBTC)}BTC"
            sellSpread = spreader 0.01, offset
            sideSell = (order)->
              R.merge side: 'sell', order

            bids.push R.map sideSell, sellSpread prices.sellBid, sellBTC

          if prices.buyBid and buyBTC > 0
            gap = ( btc.available * prices.buyBid ) - investment
            console.log "#{moment().format()} We'd want to buy #{acct.formatMoney(gap)} worth of BTC at #{acct.formatMoney(prices.buyBid)}/BTC, or #{pricing.btc(buyBTC)}BTC"
            buySpread = spreader 0.01, (-1 * offset)
            sideBuy = (order)->
              R.merge side: 'buy', order

            bids.push R.map sideBuy, buySpread prices.buyBid, buyBTC

          # console.log bids
          resolve R.flatten bids

        client.getAccounts().then determine

    # Execute new Position
    placeNewOrders = (data)->
      console.log data, 'placeNewOrders'
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

    RSVP.all(cancelPreviousOrders).then(payYourself).then(determinePosition).then(placeNewOrders).catch(onError)


  update()
  setInterval update, 1000 * 60


  stream.on 'open', ->
    stream.send JSON.stringify product_id: 'BTC-USD', type: 'subscribe'

  stream.on 'message', (data, flags) ->
    json = JSON.parse data
    if json.type is 'match'
      offset = offset * -1 if json.side is 'buy'
      price = parseFloat json.price
      bidPrice = price + offset
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
