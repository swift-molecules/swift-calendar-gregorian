public import Calendar
public import Time

extension Instant {
    public init(_ time: Gregorian.DateTime) {
        self.init(
            _unchecked: (),
            secondsSinceUnixEpoch: Int64(time.secondsSinceEpoch),
            nanosecondFraction: Int32(time.totalNanoseconds)
        )
    }
}
