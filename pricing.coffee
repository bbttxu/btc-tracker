# pricing.coffee

CBE_FEE = 1.0025
USD_PLACES = 2
BTC_PLACES = 8

fix = (places, value)->
  ( parseFloat value ).toFixed places

usd = (usd)->
  fix USD_PLACES, usd

btc = (btc, places = BTC_PLACES)->
  fix places, btc

module.exports =
  usd: usd,
  btc: btc,
  reapBtc: (size, newPrice, oldPrice)->
    newSize  = ( size * oldPrice ) / ( newPrice * CBE_FEE )

    order =
      price: usd newPrice
      size: btc newSize

  buy:
    breakEven: (price)->
      # newPrice * CBE_FEE = price
      usd ( price / CBE_FEE )

    take: (price, percentage)->
      # newPrice * CBE_FEE * percentage = price
      usd price / percentage

    takeEven: (price, percentage)->
      usd price / ( CBE_FEE * percentage )

    make: (price, percentage)->
      # newPrice * CBE_FEE * percentage = price
      usd price * ( CBE_FEE * percentage )
