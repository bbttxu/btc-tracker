require('dotenv').load()

Trip = require './trip'

Notification = require './notification'

Stream = require './stream'

Stream.on 'open', ->
  Stream.send JSON.stringify product_id: 'BTC-USD', type: 'subscribe'

Trip Stream, Notification, -0.01, 5, 'minutes'


