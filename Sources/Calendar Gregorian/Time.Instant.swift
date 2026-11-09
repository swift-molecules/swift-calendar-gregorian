public import Calendar
public import Time

extension Time.Instant {
    public init(_ time: Gregorian.DateTime) throws(Gregorian.Conversion.Error) {
        self = try Gregorian.Conversion.instant(from: time)
    }
}
