public import Calendar
public import Difference
public import Tagged

extension Gregorian {
    /// A signed count of calendar-day steps, independent of elapsed seconds.
    public struct Day {
        public let offset: DayNumber.Offset

        public init(_ offset: DayNumber.Offset) { self.offset = offset }
    }
}

extension Gregorian.Day {
    public init(_ days: Int) {
        self.init(DayNumber.Offset(Difference(days)))
    }

    public static var zero: Self { Self(0) }

    public static prefix func - (days: Self) -> Self {
        Self(DayNumber.Offset(-days.offset.underlying))
    }

    public static func + (lhs: Self, rhs: Self) throws(Difference.Error) -> Self {
        Self(DayNumber.Offset(try lhs.offset.underlying.add.exact(rhs.offset.underlying)))
    }
}

extension Gregorian.Day: Equatable {}
extension Gregorian.Day: Hashable {}
extension Gregorian.Day: Sendable {}

extension Gregorian.Date {
    public static func + (lhs: Self, rhs: Gregorian.Day) throws(Calendar<Self>.Error) -> Self {
        try Gregorian.calendar().adding(days: rhs.offset, to: lhs)
    }

    public static func - (lhs: Self, rhs: Gregorian.Day) throws(Calendar<Self>.Error) -> Self {
        try lhs + -rhs
    }

    public static func - (lhs: Self, rhs: Self) throws(Calendar<Self>.Error) -> Gregorian.Day {
        Gregorian.Day(try Gregorian.calendar().distance(from: rhs, to: lhs))
    }
}
