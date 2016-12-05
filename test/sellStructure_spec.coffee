spreadPrice = require '../lib/sellStructure'
should = require 'should'

describe "spreads price/buys out with minimum size and dollar increments", ->
  it 'calculates spread negatively', ->
    spreader = spreadPrice 0.01, -0.05

    results = spreader 432.37, 0.0321

    results.should.be.eql [
      price: '432.70'
      side: 'sell'
      size: '0.01000000'
    ,
      price: '433.69'
      side: 'sell'
      size: '0.01000000'
    ,
      price: '433.69'
      side: 'sell'
      size: '0.01210000'
    ]

