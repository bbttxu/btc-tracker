R = require 'ramda'
moment = require 'moment'

# Given a duration in seconds and  some orders,
# return those orders that are within recent time interval
module.exports = ( duration, orders )->
  cutOff = moment().subtract( duration, 's' )

  tooOld = ( offer )->
    moment( offer.time ).isBefore cutOff

  R.reject tooOld, orders

