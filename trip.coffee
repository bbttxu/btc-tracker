# trip.coffee
moment = require 'moment'
acct = require 'accounting'
R = require 'ramda'

module.exports = ( ws, sms, percentage, time, span )->

  toPct = ( decimal )->
    ( decimal * 100 ).toFixed(1) + '%'

  lastNotification = moment()
  trades = []

  console.log "Set trip at #{toPct( percentage )}% in #{time} #{span}, starting #{lastNotification.format()}"

  old = (a)->
    moment.unix(a.ms).isBefore moment().subtract( time, span )

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
      min = Math.min.apply null, prices
      max = Math.max.apply null, prices

      trades.push trade unless trades.length is 0

      pct = ( ( trade.price - max ) / max )

      if trade.price <= min and pct <= percentage

        if lastNotification.isBefore( moment().subtract( time, span ) )
          lastNotification = moment()
          trades = []

          sms
            To: process.env.PHONENUMBER
            Content: [ acct.formatMoney( trade.price / 100 ), toPct( pct ) + '%', acct.formatMoney( max / 100 ), time + ' ' + span ].join ', '


  monitorStats = ->
    trades = R.reject old, trades

    prices = getPrice trades
    times = getTimes trades

    earliest = Math.min.apply null, times
    min = Math.min.apply null, prices
    max = Math.max.apply null, prices

    console.log acct.formatMoney( min / 100), acct.formatMoney( max / 100), toPct( difference( min, max ) )

  setInterval monitorStats, 60 * 1000
