extension Gregorian.Month {

    public struct Day {
        public let rawValue: Int

        public init(_ value: Int, in month: Gregorian.Month, year: Gregorian.Year) throws(Gregorian.Month.Day.Error) {
            let count = Gregorian.daysInMonth(year, month)
            guard value >= 1, value <= count else {
                throw .invalidDay(value, daysInMonth: count, year: year)
            }
            rawValue = value
        }
    }
}

extension Gregorian.Month.Day {
    @_spi(Internal)
    public init(unchecked value: Int) { rawValue = value }

    public static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }
    public static func == (lhs: Self, rhs: Int) -> Bool { lhs.rawValue == rhs }
    public static func == (lhs: Int, rhs: Self) -> Bool { lhs == rhs.rawValue }
}

extension Gregorian.Month.Day: Sendable {}
extension Gregorian.Month.Day: Equatable {}
extension Gregorian.Month.Day: Hashable {}
extension Gregorian.Month.Day: Comparable {}
