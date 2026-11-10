public import Calendar
public import Time

extension Gregorian {

    public struct Date {
        public let year: Gregorian.Year
        public let month: Gregorian.Month
        public let day: Gregorian.Month.Day

        public init(
            year: Gregorian.Year,
            month: Gregorian.Month,
            day: Int
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
        year: Gregorian.Year,
        month: Gregorian.Month,
        day: Gregorian.Month.Day
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

extension Gregorian.Date {

    public func adding(months: Int) throws(Calendar<Self>.Error) -> Self {
        try shifted(by: Int128(months))
    }

    public func adding(years: Int) throws(Calendar<Self>.Error) -> Self {
        try shifted(by: Int128(years) * 12)
    }

    public var firstOfMonth: Self {
        Self(unchecked: year, month: month, day: Gregorian.Month.Day(unchecked: 1))
    }

    public func next(_ weekday: Gregorian.Weekday) throws(Calendar<Self>.Error) -> Self {
        try self + Gregorian.Day((Self.number(of: weekday) - Self.number(of: self.weekday) + 6) % 7 + 1)
    }

    private func shifted(by months: Int128) throws(Calendar<Self>.Error) -> Self {
        let index = Int128(year.rawValue) * 12 + Int128(month.rawValue - 1) + months
        let quotient = index / 12 - (index % 12 < 0 ? 1 : 0)
        guard let rawYear = Int(exactly: quotient) else { throw .arithmetic(.overflow) }
        let target = Gregorian.Year(rawYear)
        let targetMonth = Gregorian.Month(unchecked: Int(index - quotient * 12) + 1)
        return Self(
            unchecked: target,
            month: targetMonth,
            day: Gregorian.Month.Day(unchecked: Swift::min(day.rawValue, targetMonth.days(in: target)))
        )
    }

    private static func number(of weekday: Gregorian.Weekday) -> Int {
        switch weekday {
        case .sunday: 0
        case .monday: 1
        case .tuesday: 2
        case .wednesday: 3
        case .thursday: 4
        case .friday: 5
        case .saturday: 6
        }
    }
}

extension Gregorian.Date {

    public static func today(
        in rule: Time.Zone.Rule,
        at instant: Time.Instant
    ) throws(Gregorian.Conversion.Error) -> Self {
        try Gregorian.Conversion.dateTime(from: instant, in: rule).date
    }

    public func start(in rule: Time.Zone.Rule) throws(Gregorian.Conversion.Error) -> Time.Instant {
        let days = Gregorian.fixedDay(year: year, month: month, day: day) - Gregorian.Conversion.unixEpochDay
        guard let seconds = Int64(exactly: days * Int128(Time.Conversion.secondsPerDay)) else {
            throw .overflow
        }
        do throws(Time.Instant.Error) {
            return try rule.instant(
                local: Time.Instant(secondsSinceUnixEpoch: seconds),
                ambiguous: .earlier,
                skipped: .later
            )
        } catch {
            throw .overflow
        }
    }

    public func instants(in rule: Time.Zone.Rule) throws(Gregorian.Conversion.Error) -> Range<Time.Instant> {
        let next: Self
        do throws(Calendar<Self>.Error) {
            next = try self + Gregorian.Day(1)
        } catch {
            throw .overflow
        }
        return try start(in: rule)..<next.start(in: rule)
    }
}
