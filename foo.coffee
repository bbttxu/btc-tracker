# foo.coffee

client = require './client'


order =
  size: '.01'
  price: '100.00'

client.buy order,  ( err, response )->
  data = JSON.parse response.body
  console.log 'after buy', data
  # first.push data.client_oid
  # log data
