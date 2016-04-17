spreadPrice = require '../lib/spreadPrice'
should = require 'should'

describe "spreads price/buys out with minimum size and dollar increments", ->
  it 'calculates spread positively', ->
    spreader = spreadPrice 0.01, 0.05

    results = spreader 432.55, 0.0321

    results.should.be.eql [
      price: '432.55'
      size: '0.01210000'
    ,
      price: '432.60'
      size: '0.01000000'
    ,
      price: '432.65'
      size: '0.01000000'
    ]

  it 'calculates spread negatively', ->
    spreader = spreadPrice 0.01, -0.05

    results = spreader 432.37, 0.0321

    results.should.be.eql [
      price: '432.37'
      size: '0.01210000'
    ,
      price: '432.32'
      size: '0.01000000'
    ,
      price: '432.27'
      size: '0.01000000'
    ]

  it 'handles too small an amount', ->
    spreader = spreadPrice 0.01, 0.01

    results = spreader 432.37, 0.0021

    results.should.be.eql []
