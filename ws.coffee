require('dotenv').load()

Trip = require './trip'

Notification = require './notification'

Stream = require './stream'

Stream.on 'open', ->
  Stream.send JSON.stringify product_id: 'BTC-USD', type: 'subscribe'

Trip Stream, Notification, -0.005, 10, 'minutes', 0.05

Trip Stream, Notification, -0.01, 30, 'minutes', 0.06

Trip Stream, Notification, -0.015, 60, 'minutes', 0.07
