R = require 'ramda'
regression = require 'regression'
moment = require 'moment'

client = require './client'

price = (price, callback)->
  client.stats (err, json)->
    data = JSON.parse json.body

    now = moment()
    ago = moment().subtract 1, 'days'
    soon = moment().add(1, 'days').format('x')

    start = [ago.format('x'), data.open]
    current = [now.format('x'), price]

    # console.log [start, current]

    regression = regression 'linear', [start, current]

    equation = regression.equation
    callback [start, current]
    callback regression

    # y = m(x) + b
    # y - b = m(x)
    # x = ( y - b ) / m
    callback ( soon - equation[1] ) / equation[0]



module.exports = price
