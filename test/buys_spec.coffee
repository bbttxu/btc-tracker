buys = require '../buys'
should = require 'should'
R = require 'ramda'

describe "buys", ->
  it "are calculated", ->
    results = buys 456.78, 0.5, 467.89
    (results.length).should.be.eql 9

  it "exclude zero-gain prices", ->
    results = buys 456.78, 0.5, 458.70
    (results.length).should.be.eql 0


  it "calculate incremented penny prices", ->
    results = buys 456.78, 0.5, 467.89
    (R.pluck 'price', results).should.containEql '459.73'
    (R.pluck 'price', results).should.containEql '460.74'
