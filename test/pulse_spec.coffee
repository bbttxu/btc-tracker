should = require 'should'

pulse = require '../lib/pulse'

describe 'empty stream returns no pulse', ->
  it 'no signal', ->
    noPulse = pulse
      volume: 0.00
      priceChange: 0.00

    emptyArray = noPulse []

    emptyArray.should.be.eql false


describe 'volume signal', ->
  it 'one weak pulse', ->
    weakPulse = pulse
      volume: 1.00
      priceChange: 0.00

    weakSignal = weakPulse [
      size: 0.9
    ]

    weakSignal.should.be.eql false

  it 'several weak volume signal returns no pulse', ->
    weakPulse = pulse
      volume: 1.00
      priceChange: 0.00

    weakSignal = weakPulse [
      size: 0.1
    ,
      size: 0.1
    ,
      size: 0.1
    ]

    weakSignal.should.be.eql false

describe 'price signal', ->
  it 'only one returns no pulse', ->
    strongPulse = pulse
      volume: 0.00
      priceChange: 0.01

    positivePulse = strongPulse [
      price: 8.56
    ]

    positivePulse.should.be.eql false

  it 'several non-existant price change signal returns no pulse', ->
    weakPulse = pulse
      volume: 1.00
      priceChange: 0.00

    weakSignal = weakPulse [
      price: 8.56
    ,
      price: 8.56
    ,
      price: 8.56
    ]

    weakSignal.should.be.eql false

  it 'small insignificant positive price signal returns no pulse', ->
    strongPulse = pulse
      volume: 0.00
      price: 0.1

    positivePulse = strongPulse [
      price: 8.56
    ,
      price: 8.58
    ]

    positivePulse.should.be.eql true

  it 'small significant positive price signal returns pulse', ->
    strongPulse = pulse
      volume: 0.00
      price: 0.01

    positivePulse = strongPulse [
      price: 8.56
    ,
      price: 8.58
    ]

    positivePulse.should.be.eql true

  it 'small negative price signal returns pulse', ->
    strongPulse = pulse
      volume: 0.00
      price: -0.01

    positivePulse = strongPulse [
      price: 8.56
    ,
      price: 8.54
    ]

    positivePulse.should.be.eql true
