R = require 'ramda'

client = require './client'
notification = require './notification'
acct = require 'accounting'

BASE = 1000.0
PERCENTAGE = 0.01

take = BASE * PERCENTAGE

isUSD = (account)->
  account.currency is 'USD'

recoup = ->
  getYerTake = (err, response)->
    data = JSON.parse response.body

    account = ( R.filter isUSD, data )[0]

    overage = account.available - BASE

    if overage > take
      withdrawl =
        amount: take
        coinbase_account_id: account.id

      client.withdraw withdrawl, (err, message)->
        notification "You made #{acct.formatMoney(withdrawl.take)}!"

  client.getAccounts getYerTake

module.exports = recoup
