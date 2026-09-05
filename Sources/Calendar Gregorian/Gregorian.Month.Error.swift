extension Gregorian.Month {

    public enum Error {

        case invalidMonth(Int)
    }
}

extension Gregorian.Month.Error: Swift.Error {}
extension Gregorian.Month.Error: Equatable {}
