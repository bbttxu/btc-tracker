# pricing.coffee

CBE_FEE = 1.0025
USD_PLACES = 2

usd = (usd)->
  ( parseFloat usd ).toFixed USD_PLACES

module.exports =
  usd: usd,
  reapBtc: (size, newPrice, oldPrice)->
    newSize  = ( size * oldPrice ) / ( newPrice * CBE_FEE )

    order =
      price: newPrice
      size: newSize

  buy:
    breakEven: (price)->
      # newPrice * CBE_FEE = price
      usd ( price / CBE_FEE )

    take: (price, percentage)->
      # newPrice * CBE_FEE * percentage = price
      usd price / ( CBE_FEE * percentage )
