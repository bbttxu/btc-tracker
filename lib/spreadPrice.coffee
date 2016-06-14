R = require 'ramda'
acct = require 'accounting'
moment = require 'moment'

pricing = require '../pricing'

spreadPrice = (settings)->
  (price, size)->
    console.log "#{moment().format()} #{settings.side.toUpperCase()} #{pricing.btc(size, 3)} BTC @ #{acct.formatMoney(price)}"

    # A negative size will fail later, return early with empty array
    return [] if size < 0

    # Ensure a order meets minumum size
    # This is by design—meant to keep trading happening—and might be re-evaluated later
    # size = 0.01 if size < 0.01

    # the number of buys needed to satisfy the suggested btc order size
    buys = Math.floor size / settings.btcSize
    sizes = R.repeat settings.btcSize, buys

    # left over amounts needed to be added to fulfill cumulative order size
    remainder = size % settings.btcSize
    sizes[0] = sizes[0] + remainder if sizes[0]

    # if size is less than minumum chunk size, ensure remainder is provided
    sizes[0] = remainder unless sizes[0]

    # Create the orders
    mapIndexed = R.addIndex(R.map)
    getPrices = (orderSize, index)->
      orderPrice = ( parseFloat(price) + parseFloat(settings.usdOffset) ) + ( ( index ) * settings.usdInterval )
      order =
        price: pricing.usd orderPrice
        size: pricing.btc orderSize
        side: settings.side

    mapIndexed getPrices, sizes


module.exports = spreadPrice
