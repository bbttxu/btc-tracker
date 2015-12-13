pricing = require '../pricing'
should = require 'should'
R = require 'ramda'

describe "pricing", ->
  it "calculates increased btc order at lower dollar amount", ->
    result = pricing.reapBtc 1, 452.35, 454.35

    (result.size).should.be.eql 1.0019165637360121
    (result.price).should.be.eql 452.35

describe "pricing buys", ->
  it "calculates break even price", ->
    result = pricing.buy.breakEven '423.17'
    (result).should.be.eql '422.11'

  it "calculates price at percentage", ->
    result = pricing.buy.take '365.82', '1.01'
    (result).should.be.eql '361.29'

    result = pricing.buy.take '467.29', '1.05'
    (result).should.be.eql '443.93'
