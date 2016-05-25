R = require 'ramda'
acct = require 'accounting'
moment = require 'moment'

pricing = require '../pricing'

impact = ( fill )->
  usd = fill.size * fill.price
  usd = usd * -1.0 if fill.side is 'buy'
  usd - fill.fee

isBuy = ( fill )->
  fill.side is 'buy'

add = (a, b)->
  parseFloat(a) + parseFloat(b)

describe = (data)->
  sum =  R.sum R.map impact, data
  btc = pricing.btc (R.reduce add, 0, R.pluck 'size', data), 3
  rate = acct.formatMoney pricing.usd ( sum / btc )

  "#{acct.formatMoney(sum)}, #{btc}btc, #{rate}/btc n:#{data.length}"


foo = ( data )->
  buys = R.filter isBuy, data
  sells = R.reject isBuy, data

  allTally = describe data
  sellTally = describe sells
  buyTally = describe buys

  earliest = ( R.take 1, (R.pluck 'created_at', data).sort() )[0]
  since = "since #{moment.utc(earliest).format('YYYY/MM/DD HH:MM')}"

  [ allTally, buyTally, sellTally, since ].join "\n"

module.exports = foo
