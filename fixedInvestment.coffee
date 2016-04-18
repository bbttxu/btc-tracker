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


  offset = 0.1

  prices = {}
  updatePrices = (data)->
    prices = R.merge prices, data
    # console.log prices

  openOrders = []
  orders = []

  update = ->
    # console.log 'update'
    assess = (err, response)->
      data = JSON.parse response.body

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




      # console.log 'bids', R.flatten bids


      cancelOrder = (id)->
        # console.log 'promise to cancel ' + id
        client.cancelOrder id

      # ordersToCancel = R.pluck 'id', orders
      # console.log 'ordersToCancel', orders
      cancelPromises = R.map cancelOrder, orders

      makeOrder = (order)->
        client.order order
        # console.log order

      makeOrders = (data)->
        getId = (foo)->
          R.keys foo

        canceledOrders = R.flatten R.map getId, data

        # console.log 'cancellations done happened', canceledOrders

        removeFromActiveOrders = (id)->
          index = R.indexOf id, orders
          orders = R.remove index, 1, orders

        R.forEach removeFromActiveOrders, canceledOrders


        newOrders = R.map makeOrder, R.flatten bids

        RSVP.all(newOrders).then (data)->
          orders = orders.concat R.pluck 'id', data
          # console.log 'orders', orders


      RSVP.all(cancelPromises).then(makeOrders).catch (error)->
        console.log 'cancel order error', error

      # positiveBid = (bid)->
      #   parseFloat(bid.size) > 0

      # insufficientFunds = (bid)->
      #   parseFloat(bid.size) < 0.01

      # valid = R.reject insufficientFunds, R.filter positiveBid, R.flatten bids
      # console.log 'valid', valid
      # console.log R.equals valid, bids




    client.getAccounts assess


  update()
  setInterval update, 1000 * 20


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
