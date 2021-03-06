R = require 'ramda'
td = require 'throttle-debounce'

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

    # TODO this started failing because account is undefined
    if account

      # console.log account, ( R.filter isUSD, data )
      overage = account.available - BASE

      if overage > take
        withdrawl =
          amount: take
          # coinbase_account_id: account.id

        client.withdraw withdrawl, (err, message)->
          notification "You made #{acct.formatMoney(withdrawl.take)}!"

  client.getAccounts getYerTake

module.exports = td.debounce 1000, recoup
