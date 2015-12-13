# pricing.coffee

CBE_FEE = 1.0025

module.exports =
  reapBtc: (size, newPrice, oldPrice)->
    newSize  = ( size * oldPrice ) / ( newPrice * CBE_FEE )

    order =
      price: newPrice
      size: newSize
