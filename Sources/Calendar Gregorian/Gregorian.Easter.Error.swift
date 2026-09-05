extension Gregorian.Easter {

    public enum Error {

        case yearOutOfRange(Int)
    }
}

extension Gregorian.Easter.Error: Swift.Error {}
extension Gregorian.Easter.Error: Equatable {}
