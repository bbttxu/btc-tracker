module.exports =
  pricingOptions:
    btcSize: 0.1
    usdOffset: 0.99
    usdInterval: 0.99
    minimumSize: 0.01

  ethPricingOptions:
    btcSize: 1.0
    usdOffset: 0.01
    usdInterval: 0.01
    minimumSize: 0.1

  ltcPricingOptions:
    btcSize: 0.1
    usdOffset: 0.02
    usdInterval: 0.02
    minimumSize: 0.1


  default:
    size: 0.01
    offset: 0.22
    interval: 0.22
    mimumum: 0.1

  currencies:
    'BTC-USD': {}
    'LTC-USD': {}
    'ETH-USD': {}
    'ETH-BTC': {}
    'LTC-BTC': {}
