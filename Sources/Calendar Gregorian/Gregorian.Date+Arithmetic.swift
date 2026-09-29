public import Calendar

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
            day: Gregorian.Month.Day(unchecked: Swift.min(day.rawValue, targetMonth.days(in: target)))
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
