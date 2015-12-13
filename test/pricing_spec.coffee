pricing = require '../pricing'
should = require 'should'
R = require 'ramda'

describe "pricing", ->
  it "calculates increased btc order at lower dollar amount", ->
    result = pricing.reapBtc 1, 452.35, 454.35

    (result.size).should.be.eql 1.0019165637360121
    (result.price).should.be.eql 452.35
