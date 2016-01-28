R = require 'ramda'
acct = require 'accounting'

orderBook = require './orderBook'
redistribute = require './redistribute'
pricing = require './pricing'

orderBook.sells (data)->
  console.log data

  size = .01
  n = Math.floor data.btc / size
  avg = acct.parse data.avg



  addSize = (value)->
    value.size = pricing.btc data.btc / n
    value

  distribution = R.map addSize, redistribute.equal 433.08, avg, n

  # console.log distribution


  # console.log acct.parse data.avg
