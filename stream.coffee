# stream.coffee

WebSocket = require 'ws'

ws = new WebSocket 'wss://ws-feed.exchange.coinbase.com'

module.exports = ws
