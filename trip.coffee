# trip.coffee
moment = require 'moment'
acct = require 'accounting'
R = require 'ramda'
uuid = require 'uuid'

client = require './client'

buys = require './buys'

# buys '418.41', 0.07

module.exports = ( ws, sms, percentage, time, span )->

  toPct = ( decimal )->
    ( decimal * 100 ).toFixed(1) + '%'

  lastNotification = moment().subtract( time, span ).add( 1, span )
  trades = []

  maxPrice = undefined

  outstandingReceived = []
  waitingToBeFilled = []

  console.log "Set trip at #{toPct( percentage )}% over #{time} #{span}, starting #{lastNotification.format()}"

  old = (a)->
    moment(a.ms).isBefore moment().subtract( time, span )

  getPrice = R.pluck 'price'
  getTimes = R.pluck 'ms'

  difference = ( min, max )->
    return 0 if min is -Infinity and max is Infinity
    ( ( min - max ) / max )

  sell = (options)->
    order =
      product_id: 'BTC-USD'
      client_oid: uuid.v4()
      size: .01

    payload = R.merge order, options

    payload.size = 0.01 if payload.size < 0.01


    client.sell payload, ( err, response )->
      data = JSON.parse response.body
      console.log 'sell', err, R.pick ['price', 'size'], data

  splitSells = (price, amount, max)->
    console.log 'splitSells', price, amount, max
    R.map sell, buys price, amount, max

  buyIt = (options)->

    order =
      product_id: 'BTC-USD'
      size: .1
      client_oid: uuid.v4()
      type: 'market'


    payload = R.merge order, options
    outstandingReceived.push payload.client_oid

    client.buy payload, (err, response)->
      data = JSON.parse response.body
      console.log 'buy', err, data

  handleReceived = (json)->
    if R.contains json.client_oid, outstandingReceived
      R.remove json.client_oid, outstandingReceived
      price = ( Math.round( parseFloat( 100 * json.funds ) / parseFloat( json.size ) ) / 100 ).toFixed(2)
      splitSells price, json.size, maxPrice


  handleMatch = (json)->
    trade =
      price: json.price * 100
      ms: moment(json.time).valueOf()

    trades.push trade if trades.length is 0

    trades = R.reject old, trades

    prices = getPrice trades
    times = getTimes trades

    earliest = Math.min.apply null, times

    max = Math.max.apply null, prices

    maxPrice = max / 100.0

    trades.push trade unless trades.length is 0

    pct = ( ( trade.price - max ) / max )

    if pct <= percentage

      if lastNotification.isBefore( moment().subtract( time, span ) )
        console.log 'NOTIFY!', pct, trade.price, max

        buyIt size: 0.04

        lastNotification = moment()
        trades = []

        sms
          To: process.env.PHONENUMBER
          Content: [ acct.formatMoney( trade.price / 100 ), toPct( pct ), acct.formatMoney( max / 100 ), time + ' ' + span ].join ', '



  ws.on 'message', (data, flags) ->
    json = JSON.parse data
    handleMatch json if json.type is 'match'
    handleReceived json if json.type is 'received'


  monitorStats = ->
    trades = R.reject old, trades

    prices = getPrice trades
    times = getTimes trades

    earliest = Math.min.apply null, times
    min = Math.min.apply null, prices
    max = Math.max.apply null, prices

    console.log 'SPREAD', "#{time} #{span}", toPct( percentage), toPct( difference( max, min ) ), acct.formatMoney( ( max - min ) / 100), acct.formatMoney( min / 100), acct.formatMoney( max / 100), trades.length

  setInterval monitorStats, time * 60 * 1000

