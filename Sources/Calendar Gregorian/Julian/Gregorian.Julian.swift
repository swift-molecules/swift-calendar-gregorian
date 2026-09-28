#if Julian
@_exported public import Tagged
public import Calendar
public import Time

extension Gregorian {
    /// Julian days begin at noon UTC. Unix midnight is JD 2440587.5;
    /// day number 1 (Gregorian 0001-01-01 midnight) is JD 1721425.5.
    /// Tagged Double storage preserves day/offset identity, not nanosecond precision.
    public enum Julian {
        public enum DayDomain {}
        public enum OffsetDomain {}
        public typealias Day = Tagged<DayDomain, Double>
        public typealias Offset = Tagged<OffsetDomain, Double>
        public enum Error: Swift.Error, Equatable, Sendable {
            case nonfinite
            case unrepresentable
            case invalidCalendar
        }
    }
}

extension Tagged where Tag == Gregorian.Julian.DayDomain, Underlying == Double {
    public static var unixEpoch: Self { .init(_unchecked: 2_440_587.5) }
    public static var j2000: Self { .init(_unchecked: 2_451_545.0) }
    public static var zero: Self { .init(_unchecked: 0) }
    public var modified: Double { underlying - 2_400_000.5 }

    public init(_ instant: Time.Instant) {
        self.init(_unchecked: 2_440_587.5 + Double(instant.secondsSinceUnixEpoch) / 86400
            + Double(instant.nanosecondFraction) / 86_400_000_000_000)
    }
    public static func from(_ instant: Time.Instant) -> Self { Self(instant) }

    public init(_ dateTime: Gregorian.DateTime) throws(Gregorian.Julian.Error) {
        // Revalidate even values received through an unchecked construction API.
        do {
            _ = try Gregorian.DateTime(
                year: dateTime.year.rawValue, month: dateTime.month.rawValue,
                day: dateTime.day.rawValue, hour: dateTime.hour.value,
                minute: dateTime.minute.value, second: dateTime.second.value,
                millisecond: dateTime.millisecond.value, microsecond: dateTime.microsecond.value,
                nanosecond: dateTime.nanosecond.value)
        } catch { throw .invalidCalendar }
        guard dateTime.second.value < 60 else { throw .invalidCalendar }
        let day: DayNumber
        do { day = try Gregorian.dayNumber(of: dateTime.date) }
        catch { throw .unrepresentable }
        let seconds = Double(dateTime.hour.value * 3600 + dateTime.minute.value * 60 + dateTime.second.value)
        self.init(_unchecked: Double(day.rawValue) + 1_721_424.5
            + seconds / 86400 + Double(dateTime.totalNanoseconds) / 86_400_000_000_000)
    }
    public static func from(_ dateTime: Gregorian.DateTime) throws(Gregorian.Julian.Error) -> Self {
        try Self(dateTime)
    }
}

extension Tagged where Tag == Gregorian.Julian.OffsetDomain, Underlying == Double {
    public static var modified: Self { .init(_unchecked: 2_400_000.5) }
}

public func + (day: Gregorian.Julian.Day, offset: Gregorian.Julian.Offset) -> Gregorian.Julian.Day {
    .init(_unchecked: day.underlying + offset.underlying)
}
public func - (day: Gregorian.Julian.Day, offset: Gregorian.Julian.Offset) -> Gregorian.Julian.Day {
    .init(_unchecked: day.underlying - offset.underlying)
}
public func - (end: Gregorian.Julian.Day, start: Gregorian.Julian.Day) -> Gregorian.Julian.Offset {
    .init(_unchecked: end.underlying - start.underlying)
}

extension Time.Instant {
    public init(_ day: Gregorian.Julian.Day) throws(Gregorian.Julian.Error) {
        guard day.underlying.isFinite else { throw .nonfinite }
        let seconds = (day.underlying - 2_440_587.5) * 86400
        guard seconds.isFinite, let whole = Int64(exactly: seconds.rounded(.down)) else {
            throw .unrepresentable
        }
        let fraction = seconds - seconds.rounded(.down)
        let nanoseconds = Int32(min(max(fraction * 1_000_000_000, 0), 999_999_999))
        do { try self.init(secondsSinceUnixEpoch: whole, nanosecondFraction: nanoseconds) }
        catch { throw .unrepresentable }
    }
    public static func from(_ day: Gregorian.Julian.Day) throws(Gregorian.Julian.Error) -> Self {
        try Self(day)
    }
    public var julianDay: Gregorian.Julian.Day { .init(self) }
}

extension Calendar::DateTime where Date == Gregorian.Date {
    public init(_ day: Gregorian.Julian.Day) throws(Gregorian.Julian.Error) {
        guard day.underlying.isFinite else { throw .nonfinite }
        let fixed = day.underlying - 1_721_424.5
        let floor = fixed.rounded(.down)
        guard let rawDay = Int64(exactly: floor) else { throw .unrepresentable }
        let date: Gregorian.Date
        do { date = try Gregorian.date(on: DayNumber(rawValue: rawDay)) }
        catch { throw .unrepresentable }
        let seconds = (fixed - floor) * 86400
        let whole = min(Int(seconds), 86399)
        let nanoseconds = Int(min(max((seconds - Double(whole)) * 1_000_000_000, 0), 999_999_999))
        do {
            try self.init(year: date.year.rawValue, month: date.month, day: date.day.rawValue,
                hour: whole / 3600, minute: (whole % 3600) / 60, second: whole % 60,
                millisecond: nanoseconds / 1_000_000,
                microsecond: (nanoseconds % 1_000_000) / 1000, nanosecond: nanoseconds % 1000)
        } catch { throw .invalidCalendar }
    }
    public static func from(_ day: Gregorian.Julian.Day) throws(Gregorian.Julian.Error) -> Self { try Self(day) }
    public var julianDay: Gregorian.Julian.Day {
        get throws(Gregorian.Julian.Error) { try .init(self) }
    }
}
#endif
