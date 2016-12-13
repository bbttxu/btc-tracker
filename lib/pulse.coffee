R = require 'ramda'

pulse = ( threshold )->
  ( trades )->

    # Volume is the sum of all sizes of all trades
    volume = R.sum R.pluck 'size', trades

    # Volume signal is true if it exceeds the threshold
    volumeSignal = volume > threshold.volume

    # Price change is the difference from first to last
    prices = R.pluck 'price', trades
    firstPrice = R.take(1)(prices)[0]
    lastPrice = R.last(prices)

    # Price change is greater than the threshold
    priceSignal = Math.abs( ( lastPrice - firstPrice ) - threshold.price ) > 0

    volumeSignal or priceSignal

module.exports = pulse
