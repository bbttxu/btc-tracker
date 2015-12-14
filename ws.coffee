require('dotenv').load()

# Trip = require './trip'

# Notification = require './notification'

# Stream = require './stream'

# Stream.on 'open', ->
#   Stream.send JSON.stringify product_id: 'BTC-USD', type: 'subscribe'

# Trip Stream, Notification, -0.009, 5, 'minutes', 0.09

cleanup = require './cleanup'

cleanup 1.5, 0.25, 0.01

# Longhaul = require './longhaul'

# Longhaul 1.5, 0.25, 0.011
