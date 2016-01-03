# pricing.coffee

CBE_FEE = 1.0025
USD_PLACES = 2
BTC_PLACES = 8

usd = (usd)->
  ( parseFloat usd ).toFixed USD_PLACES

btc = (btc)->
  ( parseFloat btc ).toFixed BTC_PLACES

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
      usd price / ( CBE_FEE * percentage )

    make: (price, percentage)->
      # newPrice * CBE_FEE * percentage = price
      usd price * ( CBE_FEE * percentage )
