buys = require '../buys'
should = require 'should'
R = require 'ramda'

describe "buys", ->
  it "are calculated", ->
    results = buys 443.25, 0.5, 461.33
    (results.length).should.be.eql 10

  # it "exclude zero-gain prices", ->
  #   results = buys 456.78, 0.5, 458.80
  #   (results.length).should.be.eql 0

  # it "calculate incremented penny prices", ->
  #   results = buys 456.78, 0.02, 467.89

  #   # console.log results

  #   (R.pluck 'price', results).should.containEql '459.73'
  #   (R.pluck 'price', results).should.containEql '460.74'

  it "leak size", ->
    results = buys 456.78, 0.5, 458.78

    (R.pluck 'size', results).should.containEql '0.49912736'

    results = buys 456.78, 0.5, 459.78
    (R.sum R.map parseFloat, R.pluck 'size', results).should.be.below 0.5
