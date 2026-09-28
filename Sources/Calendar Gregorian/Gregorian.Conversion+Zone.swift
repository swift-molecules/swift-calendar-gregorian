internal import Cardinal
internal import Difference
internal import Magnitude
internal import Polarity
internal import Tagged
internal import Translation
public import Calendar
public import Time

extension Gregorian.Conversion {

    public static func instant(
        from local: Gregorian.DateTime,
        in zone: Time.Zone = .utc
    ) throws(Error) -> Time.Instant {
        guard local.second.value < 60 else { throw .unsupportedLeapSecond }
        let days = Gregorian.fixedDay(year: local.year, month: local.month, day: local.day)
            - unixEpochDay
        let seconds = days * Int128(Time.Conversion.secondsPerDay)
            + Int128(Time.Conversion.seconds(hour: local.hour, minute: local.minute, second: local.second))
        guard let seconds = Int64(exactly: seconds) else { throw .overflow }
        let coordinate = Time.Instant(
            _unchecked: (), secondsSinceUnixEpoch: seconds,
            nanosecondFraction: Int32(local.totalNanoseconds)
        )
        do {
            return try coordinate.advanced(exactly: Swift.Duration(attoseconds: -duration(of: zone).attoseconds))
        } catch {
            throw .overflow
        }
    }

    public static func dateTime(
        from instant: Time.Instant,
        in zone: Time.Zone = .utc
    ) throws(Error) -> Gregorian.DateTime {
        let local: Time.Instant
        do {
            local = try instant.advanced(exactly: duration(of: zone))
        } catch {
            throw .overflow
        }

        guard let seconds = Int(exactly: local.secondsSinceUnixEpoch) else { throw .overflow }
        return Gregorian.DateTime(
            _unchecked: (), secondsSinceEpoch: seconds,
            nanoseconds: Int(instant.nanosecondFraction)
        )
    }

    private static func duration(of zone: Time.Zone) -> Swift.Duration {
        let offset = zone.offset.underlying
        let magnitude = Int128(offset.magnitude.value.rawValue)
        let seconds = offset.polarity == .negative ? -magnitude : magnitude
        return Swift.Duration(attoseconds: seconds * 1_000_000_000_000_000_000)
    }

}

extension Calendar::DateTime where Date == Gregorian.Date {
    public func instant(in zone: Time.Zone = .utc) throws(Gregorian.Conversion.Error) -> Time.Instant {
        try Gregorian.Conversion.instant(from: self, in: zone)
    }

    public init(
        instant: Time.Instant, in zone: Time.Zone = .utc
    ) throws(Gregorian.Conversion.Error) {
        self = try Gregorian.Conversion.dateTime(from: instant, in: zone)
    }
}

extension Time.Instant {
    public func gregorian(
        in zone: Time.Zone = .utc
    ) throws(Gregorian.Conversion.Error) -> Gregorian.DateTime {
        try Gregorian.Conversion.dateTime(from: self, in: zone)
    }
}
