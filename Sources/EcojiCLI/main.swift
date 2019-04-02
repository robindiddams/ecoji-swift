import Ecoji
import Foundation

if let input = readLine() {
    let encoder = EcojiEncoder()
    if let encoded = encoder.encode(from: input) {
        print(encoded)
    }
}
