cleanSlate = require './cleanSlate'
cleanSlate.clear()

# clearStale = cleanSlate.stale
# setInterval clearStale, (1000 * 60 * 1)

LongHaul = require './LongHaul'
# LongHaul 1.001, 0.01
LongHaul 1.0016, 0.016
# LongHaul 1.002, 0.02, 2
# LongHaul 1.01, 0.1

