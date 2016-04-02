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

isUSD = (account)->
  account.currency is 'USD'


fixedInvestment = (investment, reserve, payout)->
  console.log "Maintaining #{investment} with #{reserve} reserve and payouts at #{payout}"

  prices = {}
  updatePrices = (data)->
    prices = R.merge prices, data
    console.log prices


  update = ->
    console.log 'update'
    assess = (err, response)->
      data = JSON.parse response.body
      console.log data

      usd = (R.filter isUSD, data)[0]
      console.log usd

      if usd.balance < investment
        if prices.buy
          gap = investment - usd.balance
          console.log "We'd want to buy #{acct.formatMoney(gap)} worth of BTC at #{acct.formatMoney(prices.buy)}"

      if usd.balance > investment
        gap = usd.balance - investment
        console.log "We'd want to sell #{acct.formatMoney(gap)} worth of BTC"


    client.getAccounts assess


  update()
  setInterval update, 1000 * 60


  stream.on 'open', ->
    stream.send JSON.stringify product_id: 'BTC-USD', type: 'subscribe'

  stream.on 'message', (data, flags) ->
    json = JSON.parse data
    if json.type is 'match'
      obj = {}
      obj[json.side] = json.price
      updatePrices obj


module.exports = fixedInvestment
