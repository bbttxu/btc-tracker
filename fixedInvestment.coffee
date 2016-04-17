# fixedInvestment.coffee

# The purpose of this script is to
# 1. maintain X number of BTC valued at the provided USD investment
# 2. use provided USD reserve to purchase more BTC to maintain that provided USD investment should the value fall
# 3. recoup provided USD payout once the provided investment and reserve have returned to initial values


R = require 'ramda'
# td = require 'throttle-debounce'
acct = require 'accounting'

stream = require './stream'
client = require './client'
pricing = require './pricing'

matchCurrency = (currency)->
  (account)->
    account.currency is currency

isUSD = matchCurrency 'USD'
isBTC = matchCurrency 'BTC'


fixedInvestment = (investment, reserve, payout)->
  console.log "Maintaining #{investment} with #{reserve} reserve and payouts at #{payout}"

  prices = {}
  updatePrices = (data)->
    prices = R.merge prices, data
    # console.log prices


  update = ->
    console.log 'update'
    assess = (err, response)->
      data = JSON.parse response.body
      # console.log data

      btc = (R.filter isBTC, data)[0]
      # console.log btc



      sell = btc.available * prices.sellBid
      buy = btc.available * prices.buyBid

      sellBTC = ( sell - investment ) / prices.sellBid
      buyBTC = ( investment - buy ) / prices.buyBid

      bids = []

      sellOrder =
        side: 'sell'
        size: pricing.btc sellBTC
        price: pricing.usd prices.sellBid

      bids.push sellOrder if prices.sellBid

      buyOrder =
        side: 'buy'
        size: pricing.btc(buyBTC)
        price: pricing.usd prices.buyBid

      bids.push buyOrder if prices.buyBid

      console.log 'bids', bids

      positiveBid = (bid)->
        parseFloat(bid.size) > 0

      insufficientFunds = (bid)->
        parseFloat(bid.size) < 0.01

      console.log 'valid', R.reject insufficientFunds, R.filter positiveBid, bids



      # if btc.available < investment
      #   if prices.buy
      #     gap = investment - btc.available
      #     console.log "We'd want to buy #{acct.formatMoney(gap)} worth of BTC at #{acct.formatMoney(prices.buy)}"

      # if btc.available > investment
      #   gap = btc.available - investment
      #   console.log "We'd want to sell #{acct.formatMoney(gap)} worth of BTC"


    client.getAccounts assess


  update()
  setInterval update, 1000 * 6


  stream.on 'open', ->
    stream.send JSON.stringify product_id: 'BTC-USD', type: 'subscribe'

  stream.on 'message', (data, flags) ->
    json = JSON.parse data
    if json.type is 'match'
      offset = 0.05
      offset = offset * -1 if json.side is 'buy'
      price = parseFloat json.price
      bidPrice = price + offset
      obj = {}
      obj[json.side] = price
      obj[json.side + 'Bid'] = bidPrice
      updatePrices obj


module.exports = fixedInvestment
