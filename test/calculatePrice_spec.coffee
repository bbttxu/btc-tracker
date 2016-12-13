calculatePrice = require '../lib/calculatePrice'
should = require 'should'

describe "calculate price", ->
  it "for a sell", ->
    stats =
      open: 410
      high: 440
      low: 400
      side: 'sell'
      price: 405

    result = calculatePrice stats
    should(result.price).be.eql 410

  it "for a buy", ->
    stats =
      open: 410
      high: 440
      low: 400
      side: 'buy'
      price: 405

    result = calculatePrice stats
    should(result.price).be.eql 405

  it "for unknown", ->
    stats =
      open: 410
      high: 440
      low: 400
      side: 'foo'
      price: 405

    result = calculatePrice stats
    should(result).be.eql undefined
