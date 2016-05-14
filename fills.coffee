R = require 'ramda'
acct = require 'accounting'
moment = require 'moment'

client = require './lib/coinbase-client.coffee'


impact = ( fill )->
  usd = fill.size * fill.price
  usd = usd * -1.0 if fill.side is 'buy'
  usd - fill.fee

isBuy = ( fill )->
  fill.side is 'buy'

foo = ( data )->
  earliest = ( R.take 1, (R.pluck 'created_at', data).sort() )[0]

  impacts = R.map impact, data

  total = R.sum impacts
  buys = R.sum R.map impact, R.filter isBuy, data
  sells = R.sum R.map impact, R.reject isBuy, data
  console.log acct.formatMoney(total), "(#{acct.formatMoney(buys)})", acct.formatMoney(sells), "since #{moment.utc(earliest).format('YYYY MMMM, DD')}"


client.getFills().then( foo )
