# pricing = require '../pricing'
# should = require 'should'
# R = require 'ramda'

# describe "pricing", ->
#   it 'formats dollar to cents', ->
#     result = pricing.usd 1343.454
#     result.should.be.eql '1343.45'

#     result = pricing.usd '43.729123'
#     (result).should.be.eql '43.73'

#   it "calculates increased btc order at lower dollar amount", ->
#     result = pricing.reapBtc 1, 452.35, 454.35

#     (result.size).should.be.eql '1.00191656'
#     (result.price).should.be.eql '452.35'

# describe "pricing buys", ->
#   it "calculates break even price", ->
#     result = pricing.buy.breakEven '423.17'
#     (result).should.be.eql '422.11'

#   it "calculates price at percentage", ->
#     result = pricing.buy.take '365.82', '1.01'
#     (result).should.be.eql '361.29'

#     result = pricing.buy.take '467.29', '1.05'
#     (result).should.be.eql '443.93'

#   it "calculates price removes buy percentage take", ->
#     result = pricing.buy.take '423.17', 1 / 1.0025
#     (result).should.be.eql '423.17'

#     result = pricing.buy.take '423.17', 1
#     (result).should.be.eql '422.11'

#     result = pricing.buy.take '423.17', 1.0025
#     (result).should.be.eql '421.06'

#     result = pricing.buy.take '423.17', 1.005
#     (result).should.be.eql '420.01'

#   it "pricing buy make gets make price off of buy", ->
#     result = pricing.buy.make '420.01', 1.005
#     (result).should.be.eql '423.17'
