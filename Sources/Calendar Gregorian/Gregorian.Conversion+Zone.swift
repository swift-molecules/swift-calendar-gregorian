public import Affine
public import Calendar
public import Time

extension Gregorian.Conversion {
    /// Interprets a local Gregorian label using a fixed translation from UTC.
    ///
    /// This correspondence uses uniform 86,400-second coordinate days. Leap-second
    /// labels remain valid components, but have no inverse in this correspondence.
    public static func instant(
        from local: Gregorian.DateTime,
        in zone: Time.Zone = .utc
    ) throws(Error) -> Instant {
        guard local.second.value < 60 else { throw .unsupportedLeapSecond }
        let days = Gregorian.fixedDay(year: local.year, month: local.month, day: local.day)
            - unixEpochDay
        let seconds = days * Int128(Time.Conversion.secondsPerDay)
            + Int128(Time.Conversion.seconds(hour: local.hour, minute: local.minute, second: local.second))
        guard let seconds = Int64(exactly: seconds) else { throw .overflow }
        let utc: Affine.Position<Time.Second>
        do {
            utc = try zone.inverted().applying(to: Affine.Position(rawValue: seconds))
        } catch {
            throw .overflow
        }
        return Instant(
            _unchecked: (), secondsSinceUnixEpoch: utc.rawValue,
            nanosecondFraction: Int32(local.totalNanoseconds)
        )
    }

    /// Renders a UTC instant as a local Gregorian label at a fixed numeric offset.
    public static func dateTime(
        from instant: Instant,
        in zone: Time.Zone = .utc
    ) throws(Error) -> Gregorian.DateTime {
        let local: Affine.Position<Time.Second>
        do {
            local = try zone.applying(to: instant.position)
        } catch {
            throw .overflow
        }
        // All supported targets have 64-bit Int storage. The checked conversion
        // keeps the boundary explicit for callers on any narrower target.
        guard let seconds = Int(exactly: local.rawValue) else { throw .overflow }
        return Gregorian.DateTime(
            _unchecked: (), secondsSinceEpoch: seconds,
            nanoseconds: Int(instant.nanosecondFraction)
        )
    }
}

extension Calendar::DateTime where Date == Gregorian.Date {
    public func instant(in zone: Time.Zone = .utc) throws(Gregorian.Conversion.Error) -> Instant {
        try Gregorian.Conversion.instant(from: self, in: zone)
    }

    public init(
        instant: Instant, in zone: Time.Zone = .utc
    ) throws(Gregorian.Conversion.Error) {
        self = try Gregorian.Conversion.dateTime(from: instant, in: zone)
    }
}

extension Instant {
    public func gregorian(
        in zone: Time.Zone = .utc
    ) throws(Gregorian.Conversion.Error) -> Gregorian.DateTime {
        try Gregorian.Conversion.dateTime(from: self, in: zone)
    }
}
