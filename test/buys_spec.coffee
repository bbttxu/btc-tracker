buys = require '../buys'
should = require 'should'

describe "buys", ->
  it "are calculated", ->
    results = buys 456.78, 0.5, 467.89

    (results.length).should.be.eql 9

