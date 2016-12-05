spreadPrice = require '../lib/buyStructure'
should = require 'should'

describe "spreads price/buys out with minimum size and dollar increments", ->
  it 'calculates spread positively', ->
    spreader = spreadPrice 0.01, 0.05

    results = spreader 432.55, 0.0321

    results.should.be.eql [
      price: '432.22'
      side: 'buy'
      size: '0.01000000'
    ,
      price: '431.23'
      side: 'buy'
      size: '0.01000000'
    ,
      price: '431.23'
      side: 'buy'
      size: '0.01210000'
    ]

  it 'handles too small an amount', ->
    spreader = spreadPrice 0.01, 0.01

    results = spreader 432.37, 0.01

    results.should.be.eql [
      price: '432.04'
      side: 'buy'
      size: '0.01000000'
    ]

  it 'handles a negative amount', ->
    spreader = spreadPrice 0.01, 0.01

    results = spreader 432.37, -0.0021

    results.should.be.eql []

