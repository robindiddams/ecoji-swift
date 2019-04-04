# Ecoji-Swift

A Swift 5 implementation of the [Ecoji](https://github.com/keith-turner/ecoji) encoding standard.

Provides a library for encoding and decoding data as a base-1024 sequence of emojis

## Usage

Works a lot like a JSONEncoder/Decoder

### Encoding

Encode is implemented for Data or String inputs
```swift
import Ecoji
let encoder = EcojiEncoder()
let emojiString = encoder.encode(from: "Hello World!")
print(emojiString)
// "🏯🔩🚗🌷🍉👇🦒🕊👡📢☕☕"
```
### Decoding
You can decode into Data like this:
```swift
let decoder = EcojiDecoder()
do {
  let data = try decoder.decode(string: "🏯🔩🚗🌷🍉👇🦒🕊👡📢☕☕"
  print(data)
  // "12 bytes"
} catch let err as DecodingError {
  print(err)
}
```
Theres also a convenience method for reconstruction utf strings from the data:
```swift
let decoder = EcojiDecoder()
do {
  let data = try decoder.decodeToString(string: "🏯🔩🚗🌷🍉👇🦒🕊👡📢☕☕"
  print(data)
  // "Hello World!"
} catch let err as DecodingError {
  print(err)
}
```

## TODO:
- [x] Decode/Encode
- [x] Tests
- [ ] Linux compatibility
- [ ] swift package manager
- [ ] cocoa pod

## Contribution

PRs welcome!

check test cases with  `swift test`

## License

Like the [rust implementation](https://github.com/netvl/ecoji.rs) this program is licensed under either of

 * Apache License, Version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
 * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.
