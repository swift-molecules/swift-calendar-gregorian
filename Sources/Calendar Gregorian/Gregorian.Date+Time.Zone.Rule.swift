public import Calendar
public import Time

extension Gregorian.Date {

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
