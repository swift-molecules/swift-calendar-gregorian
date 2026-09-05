extension Gregorian {
    /// A year, month and day validated together under one calendar system.
    public struct Date {
        public let year: Gregorian.Year
        public let month: Gregorian.Month
        public let day: Gregorian.Month.Day

        public init(
            year: Gregorian.Year, month: Gregorian.Month, day: Int
        ) throws(Gregorian.Month.Day.Error) {
            self.year = year
            self.month = month
            self.day = try Gregorian.Month.Day(day, in: month, year: year)
        }

    }
}

extension Gregorian.Date {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.year != rhs.year { return lhs.year < rhs.year }
        if lhs.month != rhs.month { return lhs.month < rhs.month }
        return lhs.day < rhs.day
    }

    public var weekday: Gregorian.Weekday {
        Gregorian.Weekday(year: year, month: month, day: day)
    }
}

extension Gregorian.Date: Sendable {}
extension Gregorian.Date: Equatable {}
extension Gregorian.Date: Hashable {}
extension Gregorian.Date: Comparable {}

extension Gregorian.Date {
    public init(
        year: Gregorian.Year, month: Gregorian.Month, day: Gregorian.Month.Day
    ) throws(Gregorian.Month.Day.Error) {
        try self.init(year: year, month: month, day: day.rawValue)
    }

    @_spi(Internal)
    public init(unchecked year: Gregorian.Year, month: Gregorian.Month, day: Gregorian.Month.Day) {
        self.year = year
        self.month = month
        self.day = day
    }
}
