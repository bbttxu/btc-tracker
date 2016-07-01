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

add = (summation, b)->
  size = R.prop 'size', b
  size = -1.0 * size if b.side is 'buy'
  summation + parseFloat(size)

describe = (data)->
  sum =  R.sum R.map impact, data
  btc = pricing.btc (R.reduce add, 0, data), 3
  rate = acct.formatMoney pricing.usd ( sum / btc )
  product = (R.uniq R.pluck 'product_id', data)[0].split '-'
  "#{rate}/#{product[0]} #{acct.formatMoney(sum)}, #{btc}#{product[0]}, n:#{data.length}"


foo = ( data )->
  buys = R.filter isBuy, data
  sells = R.reject isBuy, data

  allTally = describe data
  sellTally = describe sells
  buyTally = describe buys

  earliest = ( R.take 1, (R.pluck 'created_at', data).sort() )[0]
  since = "since #{moment.utc(earliest).format('YYYY/MM/DD HH:MM')}"

  [ allTally, sellTally, buyTally , since ].join "\n"

module.exports = foo
