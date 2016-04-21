module BTC where

type alias Order =
  { id: String
  , size: String
  , price: String
  }

port timestamp : Signal Int

main = timestamp 4
