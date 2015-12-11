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

  lastNotification = moment()
  trades = []

  outstandingReceived = []
  waitingToBeFilled = []

  console.log "Set trip at #{toPct( percentage )}% in #{time} #{span}, starting #{lastNotification.format()}"

  old = (a)->
    # console.log moment(a.ms).format(), moment().subtract( time, span ).format(), moment.unix(a.ms).isBefore moment().subtract( time, span )
    moment(a.ms).isBefore moment().subtract( time, span )

  getPrice = R.pluck 'price'
  getTimes = R.pluck 'ms'

  difference = ( min, max )->
    return 0 if min is -Infinity and max is Infinity
    ( ( min - max ) / max )

  sell = (options)->
    # console.log options

    order =
      product_id: 'BTC-USD'
      client_oid: uuid.v4()
      size: .01

    payload = R.merge order, options
    # console.log payload

    client.sell payload, ( err, response )->
      console.log err, response.body

  splitSells = (price, amount, max)->
    R.map sell, buys price, amount, max

  buyIt = (options)->

    order =
      product_id: 'BTC-USD'
      size: .1
      client_oid: uuid.v4()
      type: 'market'


    payload = R.merge order, options
    outstandingReceived.push payload.client_oid

    console.log payload

    client.buy payload, (err, response)->
      console.log err, response.body

  handleReceived = (json)->
    # console.log json.client_oid, outstandingReceived if json.client_oid
    if R.contains json.client_oid, outstandingReceived
      console.log json
      R.remove json.client_oid, outstandingReceived
      price = ( Math.round( parseFloat( 100 * json.funds ) / parseFloat( json.size ) ) / 100 ).toFixed(2)
      max = Math.max.apply null, prices
      splitSells price, json.size, max


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

    trades.push trade unless trades.length is 0

    pct = ( ( trade.price - max ) / max )

    if pct <= percentage

      console.log 'HIT!', pct, trade.price, max

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

    console.log 'SPREAD', toPct( difference( max, min ) ), acct.formatMoney( ( max - min ) / 100), acct.formatMoney( min / 100), acct.formatMoney( max / 100), trades.length

  setInterval monitorStats, 60 * 1000

