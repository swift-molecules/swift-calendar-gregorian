import Testing
import Time
import Calendar_Gregorian
import Calendar
import Affine
import Rational

@Suite struct Callsites {
    @Test func `quantities and clock components have distinct construction`() throws {
        let elapsed = Time.Minute(90)
        let hours = try elapsed.converted(to: Time.Hour.self)
        #expect(hours.value == (try Rational(numerator: 3, denominator: 2)))
        #expect(try elapsed + Time.Minute(15) == Time.Minute(105))
        #expect(Time.Second(-30).value == Rational(-30))
        #expect(try Time.Hour.Minute(45).value == 45)
        #expect(throws: Time.Hour.Minute.Error.self) { try Time.Hour.Minute(90) }
        #expect(try Time.Day.Hour(23).value == 23)
        #expect(try Time.Minute.Second(60).value == 60)
    }

    @Test func `civil dates and timeline arithmetic use direct callsites`() throws {
        let date = try Gregorian.Date(year: 2024, month: .february, day: 29)
        let local = try Gregorian.DateTime(date: date, hour: 23, minute: 45)
        let zone = try Time.Zone(hours: -5, minutes: 30)
        let instant = try local.instant(in: zone)
        #expect(try instant.gregorian(in: zone) == local)
        let later = try instant + Time.Minute(90)
        #expect(later - instant == .seconds(5400))
        #expect(try later - Time.Minute(90) == instant)
        let tomorrow = try date + Gregorian.Day(1)
        #expect(tomorrow.month == .march)
        #expect(tomorrow.day.rawValue == 1)
        #expect(try tomorrow - date == Gregorian.Day(1))
        #expect(try tomorrow - Gregorian.Day(1) == date)
    }

    @Test func `quantity arithmetic still checks precision and overflow`() throws {
        let maximum = Time.Second(try Rational(numerator: .max))
        #expect(throws: Rational.Error.overflow) { try maximum + Time.Second(1) }
        let origin = Instant(secondsSinceUnixEpoch: 0)
        #expect(throws: Instant.Error.precision) { try origin + Time.Picosecond(1) }
    }
}
