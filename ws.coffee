require('dotenv').load()

# Trip = require './trip'

# Notification = require './notification'

# Stream = require './stream'

# Stream.on 'open', ->
#   Stream.send JSON.stringify product_id: 'BTC-USD', type: 'subscribe'

# Trip Stream, Notification, -0.009, 5, 'minutes', 0.09

cleanup = require './cleanup'

cleanup 1.0, 0.5, 0.01

# Longhaul = require './longhaul'

# Longhaul 1.0, 0.5, 0.02
