This document describes architectural decisions which may not be clear from the code.

## Meta
Meta is the only mutable property. It can be set to null or mutated in-place. 


## Json decoding/encoding
Encoding is done via dynamic `toJson()`.
Decoding is done via static `decodeJson()`
