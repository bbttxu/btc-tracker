# trip.coffee
moment = require 'moment'
acct = require 'accounting'
R = require 'ramda'

buys = require './buys'

module.exports = ( ws, sms, percentage, time, span )->

  toPct = ( decimal )->
    ( decimal * 100 ).toFixed(1) + '%'

  lastNotification = moment()
  trades = []

  console.log "Set trip at #{toPct( percentage )}% in #{time} #{span}, starting #{lastNotification.format()}"

  old = (a)->
    # console.log moment(a.ms).format(), moment().subtract( time, span ).format(), moment.unix(a.ms).isBefore moment().subtract( time, span )
    moment(a.ms).isBefore moment().subtract( time, span )

  getPrice = R.pluck 'price'
  getTimes = R.pluck 'ms'

  difference = ( min, max )->
    return 0 if min is -Infinity and max is Infinity
    ( ( min - max ) / max )

  ws.on 'message', (data, flags) ->
    json = JSON.parse data

    if json.type is 'match'
      trade =
        price: json.price * 100
        ms: moment(json.time).valueOf()

      trades.push trade if trades.length is 0

      trades = R.reject old, trades

      prices = getPrice trades
      times = getTimes trades

      earliest = Math.min.apply null, times
      # min = Math.min.apply null, prices
      max = Math.max.apply null, prices

      trades.push trade unless trades.length is 0

      pct = ( ( trade.price - max ) / max )
      # console.log 'match', pct, trade.price, max
      if pct <= percentage

        console.log 'HIT!', pct, trade.price, max

        buys trade.price, 0.2

        if lastNotification.isBefore( moment().subtract( time, span ) )
          console.log 'NOTIFY!', pct, trade.price, max

          buys trade.price, 0.2

          lastNotification = moment()
          trades = []

          sms
            To: process.env.PHONENUMBER
            Content: [ acct.formatMoney( trade.price / 100 ), toPct( pct ), acct.formatMoney( max / 100 ), time + ' ' + span ].join ', '


  monitorStats = ->
    trades = R.reject old, trades

    prices = getPrice trades
    times = getTimes trades

    earliest = Math.min.apply null, times
    min = Math.min.apply null, prices
    max = Math.max.apply null, prices

    console.log 'SPREAD', toPct( difference( max, min ) ), acct.formatMoney( ( max - min ) / 100), acct.formatMoney( min / 100), acct.formatMoney( max / 100), trades.length

  setInterval monitorStats, 60 * 1000
